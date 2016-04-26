//
//  SevenViewController.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/26.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SevenViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface SevenViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTF;

@property (weak, nonatomic) IBOutlet UIButton *caculateBtn;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (nonatomic, strong) JSContext *context;

@end

@implementation SevenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputTF.delegate = self;
    
    self.context = [[JSContext alloc]init];
    
    // 1.加载本地js
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Seven" ofType:@"js"];
    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    // 2.执行js代码
    [self.context evaluateScript:jsScript];
}


- (IBAction)clickCaculateBtn:(UIButton *)sender {
    
    NSNumber *number = [NSNumber numberWithInteger:[self.inputTF.text integerValue]];
    
    JSValue *function = [self.context objectForKeyedSubscript:@"factorial"];
    
    JSValue *result = [function callWithArguments:@[number]];
    
    self.resultLabel.text = [NSString stringWithFormat:@"%@",[result toNumber]];
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.inputTF resignFirstResponder];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.inputTF resignFirstResponder];
    return YES;
}


@end
