//
//  FourViewController.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/19.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "FourViewController.h"
#import "GoodsModel.h"
//一定要导入
#import <JavaScriptCore/JavaScriptCore.h>

@interface FourViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    //加载本地的html
    NSString *htmlPath = [[NSBundle mainBundle]pathForResource:@"Four" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


//!!! 需要导入javascriptCore.framework
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    #pragma mark -- 方式1
    
    // 1. 首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 2. 将对象赋给js中的对象
    GoodsModel *goodsModel = [[GoodsModel alloc]init];
    // 给js注入一个对象
    context[@"SelectGoods"] = goodsModel;
    
    
    #pragma mark -- 方式2:模拟调用js方法
    
    context[@"TestSelect"] = goodsModel;
    NSString *jsStr1 = @"TestSelect.testJSToOCWithParameterOtherParameter('goodsId','price')";
    [context evaluateScript:jsStr1];
    
}

@end
