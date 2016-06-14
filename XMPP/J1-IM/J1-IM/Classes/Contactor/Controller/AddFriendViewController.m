//
//  AddFriendViewController.m
//  J1-IM
//
//  Created by liang on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "AddFriendViewController.h"
#import "XmppManager.h"
@interface AddFriendViewController ()<UITextFieldDelegate>
@property (nonatomic, weak) UITextField *searchFriendTF;
@property (nonatomic, weak) UIButton *searchBtn;
@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildView];
}

// 设置子控件
- (void)setupChildView{
    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = [UIColor lightGrayColor];
    textField.frame = CGRectMake(50, 100, 200, 40);
    self.searchFriendTF = textField;
    [self.view addSubview:textField];
    self.searchFriendTF.delegate = self;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.backgroundColor = [UIColor yellowColor];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    searchBtn.frame = CGRectMake(115, 150, 80, 40);
    [searchBtn addTarget:self action:@selector(addFriendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.searchBtn = searchBtn;
    [self.view addSubview:searchBtn];
    self.view.backgroundColor = [UIColor whiteColor];
}

// 添加好友
- (void)addFriendBtnClick{
    NSString *friendName = self.searchFriendTF.text;
    // 添加朋友的具体操作封装到xmppManager中
//    [[XmppManager sharedxmppManager] addFriendWithFriendName:friendName];
    
    [[HYXMPPManager sharedManager] addFrinedWithName:friendName aMessage:@"我是zhangsan" success:^{
        //
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSString *errorInfo) {
        //
       [[[UIAlertView alloc] initWithTitle:@"提示" message:errorInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.searchFriendTF.text.length > 0) {
        [self addFriendBtnClick];
    }
    return YES;
}

@end
