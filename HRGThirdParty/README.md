# HRGThirdPartyManager

## 注意：要添加文件里的微博、微信和QQ的SDK

注意：在Building Setting 中，other Linker Flags 添加-ObjC
1、首先导入微博、微信、QQ的SDK

2、导入一下需要的库文件：
    QuartzCore.framework 
    ImageIO.framework 
    SystemConfiguration.framework 
    Security.framework
    CoreTelephony.framework 
    CoreText.framework   
    CoreGraphics.framework 
    libz.dylib  
    libsqlite3.dylib
    libiconv.dylib
    libstdc++.dylib
    libc++.dylib

3、添加URL Type
    添加这个主要作用是告诉QQ,微信,微博到时候分享完了,返回哪个应用
    微信的话就是 Indentifer:weixin URL Schemes: 微信id
    微博是 Indentifer:weibo URL Schemes: wb+微博id
    QQ Indentifer: idtencentopenapi URL Schemes: tencent + quid

    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>weibo</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>wb631523121</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>weixin</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>wx7616c4a1ebad399a</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>QQ</string>
        </dict>
    </array>

4、在plist文件里添加iOS9 URL Schemes 白名单
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>wechat</string>
        <string>weixin</string>
        <string>sinaweibohd</string>
        <string>sinaweibo</string>
        <string>sinaweibosso</string>
        <string>weibosdk</string>
        <string>weibosdk2.5</string>
        <string>mqqapi</string>
        <string>mqq</string>
        <string>mqqOpensdkSSoLogin</string>
        <string>mqqconnect</string>
        <string>mqqopensdkdataline</string>
        <string>mqqopensdkgrouptribeshare</string>
        <string>mqqopensdkfriend</string>
        <string>mqqopensdkapi</string>
        <string>mqqopensdkapiV2</string>
        <string>mqqopensdkapiV3</string>
        <string>mqzoneopensdk</string>
        <string>wtloginmqq</string>
        <string>wtloginmqq2</string>
        <string>mqqwpa</string>
        <string>mqzone</string>
        <string>mqzonev2</string>
        <string>mqzoneshare</string>
        <string>wtloginqzone</string>
        <string>mqzonewx</string>
        <string>mqzoneopensdkapiV2</string>
        <string>mqzoneopensdkapi19</string>
        <string>mqzoneopensdkapi</string>
        <string>mqzoneopensdk</string>
    </array>
//************ 适配iOS10 **************
    <key>NSAppTransportSecurity</key>
    <dict>
    <key>NSExceptionDomains</key>
    <dict>
    <key>sina.cn</key>
    <dict>
    <key>NSIncludesSubdomains</key>
    <true/>
    <key>NSExceptionMinimumTLSVersion</key>
    <string>TLSv1.0</string>
    <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
    <false/>
    </dict>
    <key>weibo.cn</key>
    <dict>
    <key>NSIncludesSubdomains</key>
    <true/>
    <key>NSExceptionMinimumTLSVersion</key>
    <string>TLSv1.0</string>
    <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
    <false/>
    </dict>
    <key>weibo.com</key>
    <dict>
    <key>NSIncludesSubdomains</key>
    <true/>
    <key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
    <true/>
    <key>NSExceptionMinimumTLSVersion</key>
    <string>TLSv1.0</string>
    <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
    <false/>
    </dict>
    <key>sinaimg.cn</key>
    <dict>
    <key>NSIncludesSubdomains</key>
    <true/>
    <key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
    <true/>
    <key>NSExceptionMinimumTLSVersion</key>
    <string>TLSv1.0</string>
    <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
    <false/>
    </dict>
    <key>sinajs.cn</key>
    <dict>
    <key>NSIncludesSubdomains</key>
    <true/>
    <key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
    <true/>
    <key>NSExceptionMinimumTLSVersion</key>
    <string>TLSv1.0</string>
    <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
    <false/>
    </dict>
    <key>sina.com.cn</key>
    <dict>
    <key>NSIncludesSubdomains</key>
    <true/>
    <key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
    <true/>
    <key>NSExceptionMinimumTLSVersion</key>
    <string>TLSv1.0</string>
    <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
    <false/>
    </dict>
    </dict>
    </dict>

5、注册第三方应用，并在第三方应用实现从微博、微信、QQ返回
    在AppDelegate.m中引入
    #pragma mark - 从别的应用回来
    // iOS9 以上用这个方法接收
    - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    NSDictionary * dict = options;
    NSLog(@"%@", dict);
    if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.sina.weibo"]) {
    NSLog(@"新浪微博~");
    return [WeiboSDK handleOpenURL:url delegate:[HRGThirdPartyManager shareThirdPartyManager]];
    }else if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.xin"]){
    return [WXApi handleOpenURL:url delegate:[HRGThirdPartyManager shareThirdPartyManager]];
    }else if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.mqq"]){
    [HRGThirdPartyManager didReceiveTencentUrl:url];
    return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
    }

    // iOS9 以下用这个方法接收
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"%@", url);
    NSLog(@"************%@", sourceApplication);
    //新浪返回字符串@"com.sina.weibohd"，@"com.sina.weibo"分别对应微博HD和微博客户端
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
    NSLog(@"新浪微博~");
    return [WeiboSDK handleOpenURL:url delegate:[HRGThirdPartyManager shareThirdPartyManager]];
    }else if ([sourceApplication isEqualToString:@"com.tencent.xin"]){
    return [WXApi handleOpenURL:url delegate:[HRGThirdPartyManager shareThirdPartyManager]];
    //腾讯返回字符串@"com.tencent.mqq"，@"com.tencent.mipadqq"分别对应手机QQ和QQHD客户端
    }else if ([sourceApplication isEqualToString:@"com.tencent.mqq"]){
    [HRGThirdPartyManager didReceiveTencentUrl:url];
    return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
    }
