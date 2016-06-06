//
//  LoginViewController.m
//  J1-IM
//
//  Created by liang on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "UserOperation.h"
#import "XmppManager.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *hostUrlField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UserOperation *user = [UserOperation shareduser];
    self.nameField.text = user.username;
    self.passwordField.text = user.password;
    self.hostUrlField.text = user.hostUrl;
}

- (IBAction)loginBtnClick {
    NSLog(@"点击了登录按钮");
    //保存用户名和密码到偏好设置
    UserOperation *user = [UserOperation shareduser];
    user.username = self.nameField.text;
    user.password = self.passwordField.text;
    user.hostUrl = self.hostUrlField.text;
    
    // 通过xmppManager发送注册消息
    XmppManager *manager = [XmppManager sharedxmppManager];
    [self.view endEditing:YES];
    // 连接到服务器
    [manager connect:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (IBAction)registerBtnClick {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self presentViewController:registerVC animated:YES completion:nil];

}

- (void)dealloc{
    NSLog(@"登录控制器消失");
}

@end
