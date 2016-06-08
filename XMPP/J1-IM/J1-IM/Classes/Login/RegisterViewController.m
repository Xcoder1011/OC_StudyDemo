//
//  RegisterViewController.m
//  J1-IM
//
//  Created by liang on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserOperation.h"
#import "XmppManager.h"
@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *hostUrlField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerBtnClick {
    NSLog(@"点击了注册按钮");
    //保存用户名和密码到偏好设置
    UserOperation *user = [UserOperation shareduser];
    user.username = self.nameField.text;;
    user.password = self.passwordField.text;
    user.hostUrl = self.hostUrlField.text;
    
    // 通过xmppManager发送注册消息
    XmppManager *manager = [XmppManager sharedxmppManager];
    // 标记为注册操作
    manager.isRegisterOperation = YES;
    [self.view endEditing:YES];
    // 连接到服务器
    [manager connect:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
    
}

@end
