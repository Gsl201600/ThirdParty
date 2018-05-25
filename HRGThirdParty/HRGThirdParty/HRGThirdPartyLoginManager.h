//
//  HRGThirdPartyLoginManager.h
//  HRGThirdParty
//
//  Created by HRG on 2017/2/24.
//  Copyright © 2017年 HRG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define kWeiBoAppKey  @"631523121"
#define kWeiBoRedirectURI    @"你设置的微博回调页"

#define kTencentAppId   @"你的腾讯开放平台的appId"

#define kWeiXinAppId  @"wx7616c4a1ebad399a"
#define kWeiXinAppSecret @"AppSecret"

typedef NS_ENUM(NSInteger, HRGLoginType) {
    HRGLoginTypeWeiBo = 6,   // 新浪微博
    HRGLoginTypeTencent,      // QQ
    HRGLoginTypeWeiXin       // 微信
};

typedef NS_ENUM(NSInteger, HRGLoginWeiXinErrCode) {
    HRGLoginWeiXinErrCodeSuccess = 0,
    HRGLoginWeiXinErrCodeCancel = -2,
};

typedef void(^HRGThirdPartyLoginResultBlock)(NSDictionary * LoginResult, NSString * error);

@interface HRGThirdPartyLoginManager : NSObject <TencentSessionDelegate, TencentLoginDelegate, WBHttpRequestDelegate, WeiboSDKDelegate, WXApiDelegate>

+ (instancetype)shareThirdPartyLoginManager;

+ (void)getUserInfoWithLoginType:(HRGLoginType)type result:(HRGThirdPartyLoginResultBlock)result;

@end
