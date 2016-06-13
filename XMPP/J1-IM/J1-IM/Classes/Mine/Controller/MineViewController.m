//
//  MineViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "MineViewController.h"
#import "LoginViewController.h"
#import "UserOperation.h"
#import "XmppManager.h"
@interface MineViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我";
    self.nameLabel.text = [NSString stringWithFormat:@"用户名为：%@", [UserOperation shareduser].username];

    
}

- (IBAction)exitBtnClick {
    NSLog(@"退出该账号");
    // 退出该账号，发送通知切换控制器
//    [[XmppManager sharedxmppManager] logout];
    [[HYXMPPManager sharedManager] logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@(NO)];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
