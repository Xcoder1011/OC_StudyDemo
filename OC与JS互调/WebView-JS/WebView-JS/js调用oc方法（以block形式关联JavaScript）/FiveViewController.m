//
//  FiveViewController.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/19.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "FiveViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface FiveViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;


@end

@implementation FiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    //加载本地的html
    NSString *htmlPath = [[NSBundle mainBundle]pathForResource:@"Five" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


//!!! 需要导入javascriptCore.framework
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

#pragma mark -- 通过block回调
    
    // 1. 通过js方法调用OC方法
    // SelectGoods就是js的方法名
    context[@"SelectGoods"]  = ^(){
        
        //打印出所有接收到的参数
        NSArray *args = [JSContext currentArguments];
        NSLog(@"args = %@",args);
        
        //js参数是不固定的
        for (id obj in args) {
            NSLog(@"obj = %@",obj);
        }
    };
    
    
    
    // 2. 没有写后台时，可以通过模拟oc调用js方法
#warning 没有后台时模拟调用js方法必须写在block之后！！！
    // 2.1 js调用OC的block回调
    context[@"testFunct"] = ^(){
        
        NSArray *argsTest = [JSContext currentArguments];
        NSLog(@"argsTest = %@",argsTest);
        
        //js参数是不固定的
        for (id objt in argsTest) {
            NSLog(@"objt = %@",objt);
        }
    };
    
    // 2.2 准备js代码，调用js的函数testFunct
    NSString *testStr1 = @"testFunct('参数a')"; //1个参数
    [context evaluateScript:testStr1];
    
    NSString *testStr2 = @"testFunct('参数b','参数c')"; //2个参数
    [context evaluateScript:testStr2];
    
  
}


@end
