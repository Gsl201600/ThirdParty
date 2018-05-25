//
//  ViewController.m
//  HRGThirdParty
//
//  Created by HRG on 17/2/22.
//  Copyright © 2017年 HRG. All rights reserved.
//

#import "ViewController.h"
#import "HRGShareContentItem.h"
#import "HRGThirdPartyManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI{
    UIButton * btn0 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn0.frame = CGRectMake(60, 80, self.view.bounds.size.width - 120, 44);
    btn0.backgroundColor = [UIColor blueColor];
    btn0.tag = 0;
    [btn0 setTitle:@"微博分享" forState:UIControlStateNormal];
    [btn0 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn0];
    
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(60, 160, self.view.bounds.size.width - 120, 44);
    btn1.tag = 3;
    btn1.backgroundColor = [UIColor blueColor];
    [btn1 setTitle:@"微信朋友圈分享" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(60, 240, self.view.bounds.size.width - 120, 44);
    btn2.tag = 4;
    btn2.backgroundColor = [UIColor blueColor];
    [btn2 setTitle:@"微信好友分享" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton * btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(60, 320, self.view.bounds.size.width - 120, 44);
    btn3.tag = 5;
    btn3.backgroundColor = [UIColor blueColor];
    [btn3 setTitle:@"微信收藏分享" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    UIButton * btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn4.frame = CGRectMake(60, 400, self.view.bounds.size.width - 120, 44);
    btn4.tag = 1;
    btn4.backgroundColor = [UIColor blueColor];
    [btn4 setTitle:@"QQ好友分享" forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
    
    UIButton * btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn5.frame = CGRectMake(60, 480, self.view.bounds.size.width - 120, 44);
    btn5.tag = 2;
    btn5.backgroundColor = [UIColor blueColor];
    [btn5 setTitle:@"QQ空间分享" forState:UIControlStateNormal];
    [btn5 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn5];
    
    UIButton * btn6 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn6.frame = CGRectMake(60, 560, self.view.bounds.size.width - 120, 44);
    btn6.tag = 6;
    btn6.backgroundColor = [UIColor blueColor];
    [btn6 setTitle:@"微博登录" forState:UIControlStateNormal];
    [btn6 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn6];
    
    UIButton * btn7 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn7.frame = CGRectMake(60, 640, self.view.bounds.size.width - 120, 44);
    btn7.tag = 7;
    btn7.backgroundColor = [UIColor blueColor];
    [btn7 setTitle:@"QQ登录" forState:UIControlStateNormal];
    [btn7 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn7];
    
    UIButton * btn8 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn8.frame = CGRectMake(60, 720, self.view.bounds.size.width - 120, 44);
    btn8.tag = 8;
    btn8.backgroundColor = [UIColor blueColor];
    [btn8 setTitle:@"微信登录" forState:UIControlStateNormal];
    [btn8 addTarget:self action:@selector(didClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn8];
}

- (void)didClickedButton:(UIButton *)button{
    NSLog(@"%ld", (long)button.tag);
    HRGShareContentItem * item = [[HRGShareContentItem alloc] init];
    item.title = @"分享测试";
    item.summary = @"哈哈哈哈哈哈哈哈哈2!!!";
    item.urlString = @"https://www.baidu.com";
    item.sinaSummary = @"一般情况新浪微博的Summary和微信,QQ的是不同的,新浪微博的是一般带链接的,而且总共字数不能超过140字";
    
    if (button.tag == HRGShareTypeWeiXinSession) {
        [HRGThirdPartyManager shareWithContent:item shareType:HRGShareTypeWeiXinSession shareResult:^(NSInteger shareResult) {
            NSLog(@"%ld", shareResult);
        }];
//    }else if (button.tag == HRGShareTypeQQ){
//        [HRGThirdPartyManager shareWithContent:item shareType:HRGShareTypeQQ shareResult:^(NSString *shareResult) {
//            NSLog(@"*************************%@", shareResult);
//        }];
//    }else if (button.tag == HRGShareTypeQQZone){
////        [HRGThirdPartyManager shareWithContent:item shareType:3 shareResult:^(NSString *shareResult) {
////            NSLog(@"*************************%@", shareResult);
////        }];
//        [HRGThirdPartyManager shareWithContent:item shareType:4 shareResult:^(NSInteger shareResult) {
//            NSLog(@"ddd");
//        }];
//    }else if (button.tag == HRGShareTypeWeiXinTimeline){
//        [HRGThirdPartyManager shareWithContent:item shareType:HRGShareTypeWeiXinTimeline shareResult:^(NSString *shareResult) {
//            NSLog(@"*************************%@", shareResult);
//        }];
//    }else if (button.tag == HRGShareTypeWeiXinSession){
//        [HRGThirdPartyManager shareWithContent:item shareType:HRGShareTypeWeiXinSession shareResult:^(NSString *shareResult) {
//            NSLog(@"*************************%@", shareResult);
//        }];
//    }else if (button.tag == HRGShareTypeWeiXinFavorite){
//        [HRGThirdPartyManager shareWithContent:item shareType:HRGShareTypeWeiXinFavorite shareResult:^(NSString *shareResult) {
//            NSLog(@"*************************%@", shareResult);
//        }];
//    }else if (button.tag == 6){
//        [HRGThirdPartyManager getUserInfoWithLoginType:HRGLoginTypeWeiBo loginResult:^(NSDictionary *LoginResult, NSString *error) {
//            NSLog(@"%@", LoginResult);
//        }];
//    }else if (button.tag == 7){
//        [HRGThirdPartyManager getUserInfoWithLoginType:HRGLoginTypeTencent loginResult:^(NSDictionary *LoginResult, NSString *error) {
//            NSLog(@"%@", LoginResult);
//        }];
//    }else if (button.tag == 8){
//        [HRGThirdPartyManager getUserInfoWithLoginType:HRGLoginTypeWeiXin loginResult:^(NSDictionary *LoginResult, NSString *error) {
//            NSLog(@"wwwww*******%@", LoginResult);
//        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
