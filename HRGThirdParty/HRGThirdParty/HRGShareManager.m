//
//  HRGShareManager.m
//  HRGThirdParty
//
//  Created by HRG on 17/2/22.
//  Copyright © 2017年 HRG. All rights reserved.
//

#import "HRGShareManager.h"
#import "HRGShareContentItem.h"

#define kWeiBoAppKey  @"631523121"
#define kWeiBoRedirectURI  @"https://api.weibo.com/oauth2/default.html"
#define kWeiXinAppId  @"wx7616c4a1ebad399a"
#define kTencentAppId @""

//定义QQ返回状态码
#define kHRGShareQQSuccess @"0"
#define kHRGShareQQFail @"-4"

@interface HRGShareManager ()

{
    TencentOAuth * _tencentOAuth;
}

@property (nonatomic, copy) HRGShareResultBlock shareResultBlock;

@end

@implementation HRGShareManager

static HRGShareManager * shareManager;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [super allocWithZone:zone];
        [shareManager setRegisterApps];
    });
    return shareManager;
}

+ (instancetype)shareHRGShareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
        [shareManager setRegisterApps];
    });
    return shareManager;
}

// 注册appid
- (void)setRegisterApps{
    // 注册Sina微博
    [WeiboSDK registerApp:kWeiBoAppKey];
    
    // 微信注册
    [WXApi registerApp:kWeiXinAppId];
    
    // 注册QQ
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppId andDelegate:self];
}

#pragma mark - 分享方法------
+ (void)shareWithContent:(HRGShareContentItem *)contentObj shareType:(HRGShareType)shareType shareResult:(HRGShareResultBlock)shareResult{
    HRGShareManager * shareManager = [HRGShareManager shareHRGShareManager];
    shareManager.shareResultBlock = shareResult;
    
    [self shareWithContent:contentObj shareType:shareType];
}

+ (void)shareWithContent:(HRGShareContentItem *)contentObj shareType:(HRGShareType)shareType{
    switch (shareType) {
        case HRGShareTypeWeiBo:
        {
            //设置要传输的信息体
            WBMessageObject * message = [WBMessageObject message];
            message.text = contentObj.sinaSummary;
            if (contentObj.pictPath.length > 0) {
                WBImageObject * webpage = [WBImageObject object];
                webpage.imageData = [NSData dataWithContentsOfFile:contentObj.pictPath];
                message.imageObject = webpage;
            }
            
            if ([WeiboSDK isWeiboAppInstalled]) {
                //微博客户端分享
                WBSendMessageToWeiboRequest * request = [WBSendMessageToWeiboRequest requestWithMessage:message];
                [WeiboSDK sendRequest:request];
            }else{
                //微博网页分享
                WBAuthorizeRequest * authRequest = [WBAuthorizeRequest request];
                authRequest.redirectURI = kWeiBoRedirectURI;
                authRequest.scope = @"all";
                
                WBSendMessageToWeiboRequest * request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
//                request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
                [WeiboSDK sendRequest:request];
            }
        }
            break;
            
        case HRGShareTypeQQ:
        {
            if ([TencentOAuth iphoneQQInstalled]) {
                NSString * shareTitle = contentObj.qqTitle ? contentObj.qqTitle : contentObj.title;
                
                //分享跳转URL
                NSString * url = contentObj.urlString;
                QQApiNewsObject * newsObj;
                
                if (contentObj.urlImageString) {
                    newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:shareTitle description:contentObj.summary previewImageURL:[NSURL URLWithString:contentObj.urlImageString]];
                }else if (contentObj.thumbImage){
                    // 如果分享的是图片的话 不能太大所以如果后台过来的的图片太大的话 可以调节如下的倍数
                    NSData * imageData = UIImageJPEGRepresentation(contentObj.thumbImage, 1.f);
                    newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:shareTitle description:contentObj.summary previewImageData:imageData];
                }
                SendMessageToQQReq * req = [[SendMessageToQQReq alloc] init];
                req.message = newsObj;
                req.type = ESENDMESSAGETOQQREQTYPE;
                //将内容分享到qq
                [QQApiInterface sendReq:req];
            }else{
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载QQ客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeQQZone:
        {
            if ([TencentOAuth iphoneQQInstalled]) {
                //分享跳转URL
                NSString * url = contentObj.urlString;
                
                QQApiNewsObject * newObj;
                if (contentObj.urlImageString) {
                    newObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:contentObj.title description:contentObj.summary previewImageURL:[NSURL URLWithString:contentObj.urlImageString]];
                }else if (contentObj.thumbImage){
                    NSData * imageData = UIImagePNGRepresentation(contentObj.thumbImage);
                    newObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:contentObj.title description:contentObj.summary previewImageData:imageData];
                }
                //直接跳转QQ空间分享设置参数
                [newObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                SendMessageToQQReq * req = [[SendMessageToQQReq alloc] init];
                req.message = newObj;
                req.type = ESENDMESSAGETOQQREQTYPE;
                //将内容分享到qqZone
                [QQApiInterface SendReqToQZone:req];
            }else{
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载QQ客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeWeiXinTimeline:// 微信朋友圈
        {
            if ([WXApi isWXAppInstalled]) {
                WXMediaMessage * message = [WXMediaMessage message];
                message.title = contentObj.weixinPtitle.length > 0 ? contentObj.weixinPtitle : contentObj.title;
                [message setThumbImage:contentObj.thumbImage];
                message.description = contentObj.summary;
                WXWebpageObject * ext = [WXWebpageObject object];
                ext.webpageUrl = contentObj.urlString;
                message.mediaObject = ext;
                SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = WXSceneTimeline;
                [WXApi sendReq:req];
            }else{
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载微信客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeWeiXinSession:
        {
            if ([WXApi isWXAppInstalled]) {
                WXMediaMessage * message = [WXMediaMessage message];
                message.title = contentObj.title;
                [message setThumbImage:contentObj.thumbImage];
                message.description = contentObj.summary;
                WXWebpageObject * ext = [WXWebpageObject object];
                ext.webpageUrl = contentObj.urlString;
                message.mediaObject = ext;
                
                SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = WXSceneSession;
                [WXApi sendReq:req];
            }else{
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载微信客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        case HRGShareTypeWeiXinFavorite:
        {
            if ([WXApi isWXAppInstalled]) {
                WXMediaMessage * message = [WXMediaMessage message];
                message.title = contentObj.title;
                [message setThumbImage:contentObj.thumbImage];
                message.description = contentObj.summary;
                WXWebpageObject * ext = [WXWebpageObject object];
                ext.webpageUrl = contentObj.urlString;
                message.mediaObject = ext;
                
                SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = WXSceneFavorite;
                [WXApi sendReq:req];
            }else{
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请移步App Store去下载微信客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - WeiboSDKDelegate 从新浪微博那边分享过来传回一些数据调用的方法
/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
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
    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        //NSLog(@"微博----分享成功!!!");
        self.shareResultBlock(@"微博----分享成功!!!");
    }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
        //        NSLog(@"微博----用户取消发送");
        self.shareResultBlock(@"微博----用户取消发送");
    }else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail){
        //        NSLog(@"微博----发送失败!");
        self.shareResultBlock(@"微博----发送失败!");
    }
}

#pragma mark - WXApiDelegate 从微信那边分享过来传回一些数据调用的方法
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp{
    // 成功回来
    // errCode  0
    // type     0
    
    // 取消分享回来
    // errCode -2
    // type 0
    if (resp.errCode == HRGShareWeiXinErrCodeSuccess) {
        //        NSLog(@"微信----分享成功!!");
        self.shareResultBlock(@"微信----分享成功!!");
    }else{
        //        NSLog(@"微信----用户取消分享!!");
        self.shareResultBlock(@"微信----用户取消分享!!");
    }
}

#pragma mark - 判断qq是否分享成功
+ (void)didReceiveTencentUrl:(NSURL *)url{
    NSString * urlStr = url.absoluteString;
    NSArray * array = [urlStr componentsSeparatedByString:@"error="];
    if (array.count > 1) {
        NSString * lastStr = [array lastObject];
        NSArray * lastStrArray = [lastStr componentsSeparatedByString:@"&"];
        NSString * resultStr = [lastStrArray firstObject];
        if ([resultStr isEqualToString:kHRGShareQQSuccess]) {
            //            NSLog(@"QQ------分享成功!");
            shareManager.shareResultBlock(@"QQ------分享成功!");
        }else if ([resultStr isEqualToString:kHRGShareQQFail]){
            //            NSLog(@"QQ------分享失败!");
            shareManager.shareResultBlock(@"QQ------分享失败!");
        }
    }
}

- (void)tencentDidLogin{
    NSLog(@"登录");
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    NSLog(@"取消登录%d", cancelled);
}

- (void)tencentDidNotNetWork{
    NSLog(@"无网络连接");
}

@end
