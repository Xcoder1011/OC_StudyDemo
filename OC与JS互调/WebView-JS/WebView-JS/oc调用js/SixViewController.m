//
//  SixViewController.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/19.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SixViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface SixViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;


@property (nonatomic, strong) JSContext *context;

@end

@implementation SixViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    //加载本地的html
    NSString *htmlPath = [[NSBundle mainBundle]pathForResource:@"Six" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"登录" style:UIBarButtonItemStylePlain target:self action:@selector(loginClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
     [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
}


#pragma mark -- OC调用JS方式一
-(void)loginClick{
    
    // 1.不传参数
    [_context evaluateScript:@"login()"];
    
    // 2.传参数
    // 如login('abc'),而js中的就是var login = function(param){}
     [_context evaluateScript:@"loginWithParam('参数abc')"];

}

//!!! 需要导入javascriptCore.framework
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _context = context;
    
#pragma mark -- OC调用JS方式二
    NSString *alertJS = @"alert('网络加载完毕后弹框！')";
    [context evaluateScript:alertJS];
}



@end
