//
//  HRGShareManager.h
//  HRGThirdParty
//
//  Created by HRG on 17/2/22.
//  Copyright © 2017年 HRG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

typedef NS_ENUM(NSInteger, HRGShareType) {
    HRGShareTypeWeiBo = 0,     // 新浪微博
    HRGShareTypeQQ,            // QQ好友
    HRGShareTypeQQZone,        // QQ空间
    HRGShareTypeWeiXinTimeline,// 朋友圈
    HRGShareTypeWeiXinSession, // 微信朋友
    HRGShareTypeWeiXinFavorite,// 微信收藏
};

typedef NS_ENUM(NSInteger, HRGShareWeiXinErrCode) {
    HRGShareWeiXinErrCodeSuccess = 0,  //微信返回状态码
    HRGShareWeiXinErrCodeCancel = -2,
};

@class HRGShareContentItem;

typedef void(^HRGShareResultBlock)(NSString * shareResult);

@interface HRGShareManager : NSObject <WBHttpRequestDelegate, WeiboSDKDelegate, WXApiDelegate, TencentSessionDelegate>

+ (instancetype)shareHRGShareManager;

// 判断QQ分享是否成功
+ (void)didReceiveTencentUrl:(NSURL *)url;
+ (void)shareWithContent:(HRGShareContentItem *)contentObj shareType:(HRGShareType)shareType shareResult:(HRGShareResultBlock)shareResult;

@end
