//
//  HRGThirdPartyLoginManager.m
//  HRGThirdParty
//
//  Created by HRG on 2017/2/24.
//  Copyright © 2017年 HRG. All rights reserved.
//

#import "HRGThirdPartyLoginManager.h"

@interface HRGThirdPartyLoginManager () <NSURLSessionTaskDelegate>

@property (nonatomic, copy) HRGThirdPartyLoginResultBlock resultBlock;
@property (nonatomic, assign) HRGLoginType loginType;
@property (nonatomic, strong) NSString * access_token;

@property (nonatomic, strong) TencentOAuth * tencentOAuth;
@property (nonatomic, strong) NSMutableArray * tencentPermissions;

@end

@implementation HRGThirdPartyLoginManager

static HRGThirdPartyLoginManager * loginManager;

+ (void)initialize{
    [HRGThirdPartyLoginManager shareThirdPartyLoginManager];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginManager = [super allocWithZone:zone];
        [loginManager setRegisterApps];
    });
    return loginManager;
}

+ (instancetype)shareThirdPartyLoginManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loginManager = [[self alloc] init];
        [loginManager setRegisterApps];
    });
    return loginManager;
}

// 注册appid
- (void)setRegisterApps{
    // 注册Sina微博
    [WeiboSDK registerApp:kWeiBoAppKey];
    // 微信注册
    [WXApi registerApp:kWeiXinAppId];
    // 注册QQ
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppId andDelegate:self];
    // 这个是说到时候你去qq那拿什么信息
//    /** 获取用户信息 */
//    kOPEN_PERMISSION_GET_USER_INFO,
//    /** 移动端获取用户信息 */
//    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
//    /** 获取登录用户自己的详细信息 */
//    kOPEN_PERMISSION_GET_INFO
    _tencentPermissions = [NSMutableArray arrayWithArray:@[kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_GET_INFO]];
}

+ (void)getUserInfoWithLoginType:(HRGLoginType)type result:(HRGThirdPartyLoginResultBlock)result{
    HRGThirdPartyLoginManager * loginManager = [HRGThirdPartyLoginManager shareThirdPartyLoginManager];
    
    loginManager.resultBlock = result;
    loginManager.loginType = type;
    if (type == HRGLoginTypeWeiBo) {
        WBAuthorizeRequest * request = [WBAuthorizeRequest request];
        request.redirectURI = kWeiBoRedirectURI;
//        request.scope = @"follow_app_official_microblog";
        [WeiboSDK sendRequest:request];
    }else if (type == HRGLoginTypeTencent){
        [loginManager.tencentOAuth authorize:loginManager.tencentPermissions];
    }else if (type == HRGLoginTypeWeiXin){
        //构造SendAuthReq结构体
        SendAuthReq * req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        //第三方向微信终端发送一个SendAuthReq消息结构
        [WXApi sendReq:req];
    }
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp{
    SendAuthResp * aresp = (SendAuthResp *)resp;
    if (resp.errCode == HRGLoginWeiXinErrCodeSuccess) {
        NSString * code = aresp.code;
        [loginManager getWeiXinUserInfoWithCode:code];
    }else{
        if (self.resultBlock) {
            self.resultBlock(nil, @"授权失败");
        }
    }
}

- (void)getWeiXinUserInfoWithCode:(NSString *)code{
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation * getAccessTokenOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString * urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@grant_type=authorization_code", kWeiXinAppId, kWeiXinAppSecret, code];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSString * responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData * responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.access_token = dict[@"access_token"];
    }];
    
    NSBlockOperation * getUserInfoOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString * urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", self.access_token, kWeiXinAppId];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSString * responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData * responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSDictionary * paramter = @{@"third_id":dict[@"openid"], @"third_name":dict[@"nickname"], @"third_image":dict[@"headimgurl"], @"access_token":self.access_token};
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _resultBlock(paramter, nil);
        }];
    }];
    
    [getUserInfoOperation addDependency:getAccessTokenOperation];
    
    [queue addOperation:getAccessTokenOperation];
    [queue addOperation:getUserInfoOperation];
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin{
    [_tencentOAuth getUserInfo];
}

- (void)getUserInfoResponse:(APIResponse *)response{
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSLog(@"%@", response.jsonResponse);
        NSLog(@"openID : %@", [_tencentOAuth openId]);
        NSDictionary * paramter = @{@"third_id":[_tencentOAuth openId], @"third_name":[response.jsonResponse valueForKeyPath:@"nickname"], @"third_image":[response.jsonResponse valueForKeyPath:@"figureurl_qq_2"], @"access_token":[_tencentOAuth accessToken]};
        if (self.resultBlock) {
            self.resultBlock(paramter, nil);
        }
    }else{
        NSLog(@"登录失败");
    }
}

- (void)tencentDidLogout{
    NSLog(@"登出");
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    NSLog(@"取消登录%d", cancelled);
}

- (void)tencentDidNotNetWork{
    NSLog(@"无网络连接");
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    NSLog(@"weibo请求");
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    NSLog(@"token : %@", [(WBAuthorizeResponse *)response accessToken]);
    NSLog(@"uid : %@", [(WBAuthorizeResponse *)response userID]);
    [self getWeiBoUserInfo:[(WBAuthorizeResponse *)response userID] token:[(WBAuthorizeResponse *)response accessToken]];
}

- (void)getWeiBoUserInfo:(NSString *)uid token:(NSString *)token{
    NSString * urlStr = [NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?uid=%@&access_token=%@&source=%@", uid, token, kWeiBoAppKey];
    NSURL * url = [NSURL URLWithString:urlStr];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // 创建任务
    NSURLSessionDataTask * task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", [NSThread currentThread]);
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@", dict);
        
        NSDictionary * paramter = @{@"third_id":[dict valueForKeyPath:@"idstr"], @"third_name":[dict valueForKeyPath:@"screen_name"], @"third_image":[dict valueForKeyPath:@"avatar_hd"], @"access_token":token};
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (self.resultBlock) {
                _resultBlock(paramter, nil);
            }
        }];
    }];
    // 启动任务
    [task resume];
}

@end
