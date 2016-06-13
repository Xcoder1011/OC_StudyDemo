//
//  AppDelegate.m
//  J1-IM
//
//  Created by wushangkun on 16/1/21.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "AppDelegate.h"
#import "HYTabBarController.h"
#import "LoginViewController.h"
#import "UserOperation.h"
#import "XmppManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [self defaultsViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchRootViewController:) name:LoginResultNotification object:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

/** 登陆状态改变调用 */
- (void)switchRootViewController:(NSNotification *)noti{
    NSLog(@"登录状态改变");
    if ([noti.object intValue]) {
        // 账号密码正确到主界面
        self.window.rootViewController = [[HYTabBarController alloc] init];
    }else{
        // 账号密码错误在登录界面
        self.window.rootViewController = [[LoginViewController alloc] init];
    }
}

/** 返回登录默认控制器 */
- (UIViewController *)defaultsViewController{
    if ([UserOperation shareduser].loginStatus) {
        return [[HYTabBarController alloc] init];
    }else{
        return [[LoginViewController alloc] init];
    }
}


// 移除通知
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 当程序被激活的时候连接到服务器
- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"程序激活，连接到服务器");
    [[XmppManager sharedxmppManager] connect:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的密码可能在其他的计算机上被修改，请重新登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
    
//    [HYXMPPManager sharedManager];
    
}

// 程序退出的时候断开连接
- (void)applicationWillTerminate:(UIApplication *)application{
    NSLog(@"程序进程被销毁");
    [[XmppManager sharedxmppManager] teardownXmppStream];
//    [[HYXMPPManager sharedManager] teardownXmppStream];
}
@end
