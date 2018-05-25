//
//  HRGThirdPartyManager.m
//  HRGThirdParty
//
//  Created by HRG on 2017/2/27.
//  Copyright © 2017年 HRG. All rights reserved.
//

#import "HRGThirdPartyManager.h"
#import "HRGShareContentItem.h"

//定义QQ返回状态码
#define kHRGShareQQSuccess  @"0"
#define kHRGShareQQFail  @"-4"

@interface HRGThirdPartyManager () <NSURLSessionTaskDelegate, WBHttpRequestDelegate, WeiboSDKDelegate, WXApiDelegate, TencentSessionDelegate, TencentLoginDelegate>

@property (nonatomic, copy) HRGLoginResultBlock loginResultBlock;
@property (nonatomic, copy) HRGShareResultBlock shareResultBlock;

@property (nonatomic, assign) BOOL isLoginState;

@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, strong) NSMutableArray *tencentPermissions;

@end

@implementation HRGThirdPartyManager

static HRGThirdPartyManager *thirdPartyManager = nil;

+ (void)initialize{
    [HRGThirdPartyManager shareThirdPartyManager];
}

+ (instancetype)shareThirdPartyManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thirdPartyManager = [[self alloc] init];
        [thirdPartyManager setRegisterApps];
    });
    return thirdPartyManager;
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

//第三方登录方法
+ (void)getUserInfoWithLoginType:(HRGLoginType)loginType loginResult:(HRGLoginResultBlock)loginResult{
    thirdPartyManager.loginResultBlock = loginResult;
    thirdPartyManager.isLoginState = YES;
    switch (loginType) {
        case HRGLoginTypeWeiBo:
        {
            WBAuthorizeRequest *request = [WBAuthorizeRequest request];
            request.redirectURI = kWeiBoRedirectURI;
//            request.scope = @"follow_app_official_microblog";
            [WeiboSDK sendRequest:request];
        }
            break;
            
        case HRGLoginTypeTencent:
            [thirdPartyManager.tencentOAuth authorize:thirdPartyManager.tencentPermissions];
            break;
            
        case HRGLoginTypeWeiXin:
        {
            //构造SendAuthReq结构体
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.scope = @"snsapi_userinfo";
            //第三方向微信终端发送一个SendAuthReq消息结构
            [WXApi sendReq:req];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 分享方法------
+ (void)shareWithContent:(HRGShareContentItem *)contentObj shareType:(HRGShareType)shareType shareResult:(HRGShareResultBlock)shareResult{
    thirdPartyManager.shareResultBlock = shareResult;
    thirdPartyManager.isLoginState = NO;
    [self shareWithContent:contentObj shareType:shareType];
}

+ (void)shareWithContent:(HRGShareContentItem *)contentObj shareType:(HRGShareType)shareType{
    switch (shareType) {
        case HRGShareTypeWeiBo:
        {
            //设置要传输的信息体
            WBMessageObject *message = [WBMessageObject message];
            message.text = contentObj.sinaSummary;
            if (contentObj.pictPath.length > 0) {
                WBImageObject *webpage = [WBImageObject object];
                webpage.imageData = [NSData dataWithContentsOfFile:contentObj.pictPath];
//                webpage.imageData = UIImageJPEGRepresentation(contentObj.bigImage, 1.f);
                message.imageObject = webpage;
            }
            
//            imageObject.imageData = [NSData dataWithContentsOfFile:contentObj.pictPath];
//            message.mediaObject = imageObject;
//            SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
            
            if ([WeiboSDK isWeiboAppInstalled]) {
                //微博客户端分享
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
                [WeiboSDK sendRequest:request];
            }else{
                //微博网页分享
                WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
                authRequest.redirectURI = kWeiBoRedirectURI;
                authRequest.scope = @"all";
                
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
//                request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
                [WeiboSDK sendRequest:request];
            }
        }
            break;
            
        case HRGShareTypeQQ:
        {
            if ([TencentOAuth iphoneQQInstalled]) {
                NSString *shareTitle = contentObj.qqTitle ? contentObj.qqTitle : contentObj.title;
                
                //分享跳转URL
                NSString *url = contentObj.urlString;
                QQApiNewsObject *newsObj;
                
                if (contentObj.urlImageString) {
                    newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:shareTitle description:contentObj.summary previewImageURL:[NSURL URLWithString:contentObj.urlImageString]];
                }else if (contentObj.thumbImage){
                    // 如果分享的是图片的话 不能太大所以如果后台过来的的图片太大的话 可以调节如下的倍数
                    NSData *imageData = UIImageJPEGRepresentation(contentObj.thumbImage, 1.f);
                    newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:shareTitle description:contentObj.summary previewImageData:imageData];
                }
                SendMessageToQQReq *req = [[SendMessageToQQReq alloc] init];
                req.message = newsObj;
                req.type = ESENDMESSAGETOQQREQTYPE;
                //将内容分享到qq
                [QQApiInterface sendReq:req];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载QQ客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeQQZone:
        {
            if ([TencentOAuth iphoneQQInstalled]) {
                //分享跳转URL
                NSString *url = contentObj.urlString;
                
                QQApiNewsObject *newObj;
                if (contentObj.urlImageString) {
                    newObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:contentObj.title description:contentObj.summary previewImageURL:[NSURL URLWithString:contentObj.urlImageString]];
                }else if (contentObj.thumbImage){
                    NSData *imageData = UIImagePNGRepresentation(contentObj.thumbImage);
                    newObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:contentObj.title description:contentObj.summary previewImageData:imageData];
                }
                //直接跳转QQ空间分享设置参数
                [newObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                SendMessageToQQReq *req = [[SendMessageToQQReq alloc] init];
                req.message = newObj;
                req.type = ESENDMESSAGETOQQREQTYPE;
                //将内容分享到qqZone
                [QQApiInterface SendReqToQZone:req];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载QQ客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeWeiXinTimeline:// 微信朋友圈
        {
            if ([WXApi isWXAppInstalled]) {
                if (contentObj.isImageShareWX) {
                    //分享图片
                    WXMediaMessage *message = [WXMediaMessage message];
                    WXImageObject *imageObject = [WXImageObject object];
//                    NSString * filepath = [[NSBundle mainBundle] pathForResource:@"Snip" ofType:@"png"];
//                    NSLog(@"%@", filepath);
                    imageObject.imageData = [NSData dataWithContentsOfFile:contentObj.pictPath];
                    message.mediaObject = imageObject;
                    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                    req.bText = NO;
                    req.message = message;
                    req.scene = WXSceneTimeline;
                    [WXApi sendReq:req];
                }else{
                    WXMediaMessage *message = [WXMediaMessage message];
                    message.title = contentObj.weixinPtitle.length > 0 ? contentObj.weixinPtitle : contentObj.title;
                    [message setThumbImage:contentObj.thumbImage];
                    message.description = contentObj.summary;
                    WXWebpageObject *ext = [WXWebpageObject object];
                    ext.webpageUrl = contentObj.urlString;
                    message.mediaObject = ext;
                    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                    req.bText = NO;
                    req.message = message;
                    req.scene = WXSceneTimeline;
                    [WXApi sendReq:req];
                }
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载微信客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeWeiXinSession:
        {
            if ([WXApi isWXAppInstalled]) {
                if (contentObj.isImageShareWX) {
                    //分享图片
                    WXMediaMessage *message = [WXMediaMessage message];
                    WXImageObject *imageObject = [WXImageObject object];
//                    NSString * filepath = [[NSBundle mainBundle] pathForResource:@"Snip" ofType:@"png"];
//                    NSLog(@"%@", filepath);
                    imageObject.imageData = [NSData dataWithContentsOfFile:contentObj.pictPath];
                    message.mediaObject = imageObject;
                    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                    req.bText = NO;
                    req.message = message;
                    req.scene = WXSceneSession;
                    [WXApi sendReq:req];
                }else{
                    WXMediaMessage *message = [WXMediaMessage message];
                    message.title = contentObj.title;
                    [message setThumbImage:contentObj.thumbImage];
                    message.description = contentObj.summary;
                    WXWebpageObject *ext = [WXWebpageObject object];
                    ext.webpageUrl = contentObj.urlString;
                    message.mediaObject = ext;
                    
                    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                    req.bText = NO;
                    req.message = message;
                    req.scene = WXSceneSession;
                    [WXApi sendReq:req];
                }
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载微信客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeWeiXinFavorite:
        {
            if ([WXApi isWXAppInstalled]) {
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = contentObj.title;
                [message setThumbImage:contentObj.thumbImage];
                message.description = contentObj.summary;
                WXWebpageObject *ext = [WXWebpageObject object];
                ext.webpageUrl = contentObj.urlString;
                message.mediaObject = ext;
                
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = WXSceneFavorite;
                [WXApi sendReq:req];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载微信客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        default:
            break;
    }
}

//****************登录和分享的回调********************
#pragma mark - WXApiDelegate 从微信那边分享过来传回一些数据调用的方法
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp{
    if (self.isLoginState) {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (resp.errCode == HRGWeiXinErrCodeSuccess) {
            NSString *code = aresp.code;
            [thirdPartyManager getWeiXinUserInfoWithCode:code];
        }else{
            if (self.loginResultBlock) {
                self.loginResultBlock(nil, @"授权失败");
            }
        }
    }else{
        // 成功回来
        // errCode  0
        // type     0
        
        // 取消分享回来
        // errCode -2
        // type 0
        self.shareResultBlock(resp.errCode);
//        if (resp.errCode == HRGWeiXinErrCodeSuccess) {
//            //        NSLog(@"微信----分享成功!!");
//            self.shareResultBlock(@"微信----分享成功!!");
//        }else{
//            //        NSLog(@"微信----用户取消分享!!");
//            self.shareResultBlock(@"微信----用户取消分享!!");
//        }
    }
}

- (void)getWeiXinUserInfoWithCode:(NSString *)code{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *getAccessTokenOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", kWeiXinAppId, kWeiXinAppSecret, code];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.access_token = dict[@"access_token"];
    }];
    
    NSBlockOperation *getUserInfoOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", self.access_token, kWeiXinAppId];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSDictionary *paramter = @{@"third_id":dict[@"openid"], @"third_name":dict[@"nickname"], @"third_image":dict[@"headimgurl"], @"access_token":self.access_token};
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _loginResultBlock(paramter, nil);
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
        NSDictionary *paramter = @{@"third_id":[_tencentOAuth openId], @"third_name":[response.jsonResponse valueForKeyPath:@"nickname"], @"third_image":[response.jsonResponse valueForKeyPath:@"figureurl_qq_2"], @"access_token":[_tencentOAuth accessToken]};
        if (self.loginResultBlock) {
            self.loginResultBlock(paramter, nil);
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

#pragma mark - 判断qq是否分享成功
+ (void)didReceiveTencentUrl:(NSURL *)url{
    NSString *urlStr = url.absoluteString;
    NSArray *array = [urlStr componentsSeparatedByString:@"error="];
    if (array.count > 1) {
        NSString *lastStr = [array lastObject];
        NSArray *lastStrArray = [lastStr componentsSeparatedByString:@"&"];
        NSString *resultStr = [lastStrArray firstObject];
        NSInteger resultCode = [resultStr integerValue];
        thirdPartyManager.shareResultBlock(resultCode);
//        if ([resultStr isEqualToString:kHRGShareQQSuccess]) {
//            //            NSLog(@"QQ------分享成功!");
//            thirdPartyManager.shareResultBlock(@"QQ------分享成功!");
//        }else if ([resultStr isEqualToString:kHRGShareQQFail]){
//            //            NSLog(@"QQ------分享失败!");
//            thirdPartyManager.shareResultBlock(@"QQ------分享失败!");
//        }
    }
}

#pragma mark - WeiboSDKDelegate 从新浪微博那边分享过来传回一些数据调用的方法
/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    NSLog(@"weibo请求");
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if (self.isLoginState) {
        NSLog(@"token : %@", [(WBAuthorizeResponse *)response accessToken]);
        NSLog(@"uid : %@", [(WBAuthorizeResponse *)response userID]);
        [self getWeiBoUserInfo:[(WBAuthorizeResponse *)response userID] token:[(WBAuthorizeResponse *)response accessToken]];
    }else{
        /**
         WeiboSDKResponseStatusCodeSuccess               = 0,//成功
         WeiboSDKResponseStatusCodeUserCancel            = -1,//用户取消发送
         WeiboSDKResponseStatusCodeSentFail              = -2,//发送失败
         WeiboSDKResponseStatusCodeAuthDeny              = -3,//授权失败
         WeiboSDKResponseStatusCodeUserCancelInstall     = -4,//用户取消安装微博客户端
         WeiboSDKResponseStatusCodePayFail               = -5,//支付失败
         WeiboSDKResponseStatusCodeShareInSDKFailed      = -8,//分享失败 详情见response UserInfo
         WeiboSDKResponseStatusCodeUnsupport             = -99,//不支持的请求
         WeiboSDKResponseStatusCodeUnknown               = -100,
         */
        self.shareResultBlock(response.statusCode);
//        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
//            //NSLog(@"微博----分享成功!!!");
//            self.shareResultBlock(@"微博----分享成功!!!");
//        }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
//            //        NSLog(@"微博----用户取消发送");
//            self.shareResultBlock(@"微博----用户取消发送");
//        }else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail){
//            //        NSLog(@"微博----发送失败!");
//            self.shareResultBlock(@"微博----发送失败!");
//        }
    }
}

- (void)getWeiBoUserInfo:(NSString *)uid token:(NSString *)token{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?uid=%@&access_token=%@&source=%@", uid, token, kWeiBoAppKey];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // 创建任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", [NSThread currentThread]);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSDictionary *paramter = @{@"third_id":[dict valueForKeyPath:@"idstr"], @"third_name":[dict valueForKeyPath:@"screen_name"], @"third_image":[dict valueForKeyPath:@"avatar_hd"], @"access_token":token};
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (self.loginResultBlock) {
                _loginResultBlock(paramter, nil);
            }
        }];
    }];
    // 启动任务
    [task resume];
}

@end
