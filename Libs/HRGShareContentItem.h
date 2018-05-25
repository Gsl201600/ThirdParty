//
//  HRGShareContentItem.h
//  HRGThirdParty
//
//  Created by HRG on 17/2/22.
//  Copyright © 2017年 HRG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HRGShareContentItem : NSObject

// 分享图片
@property (nonatomic, strong) UIImage *thumbImage;
// 分享标题
@property (nonatomic, copy) NSString *title;
// 分享所需图片地址
@property (nonatomic, copy) NSString * pictPath;
// 微信分享标题
@property (nonatomic, copy) NSString *weixinPtitle;
// QQ分享标题
@property (nonatomic, copy) NSString *qqTitle;
// 分享跳转url地址
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *urlImageString;// QQ,QQ空间分享加载图片用的

// 微信、QQ分享内容
@property (nonatomic, copy) NSString *summary;
// 微信分享是否带图片
@property (nonatomic, assign) BOOL isImageShareWX;
// 微博分享内容
@property (nonatomic, copy) NSString *sinaSummary;

@end
