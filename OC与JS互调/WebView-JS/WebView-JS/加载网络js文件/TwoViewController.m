//
//  TwoViewController.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/19.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "TwoViewController.h"

@interface TwoViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    //加载本地的html
    NSString *htmlPath = [[NSBundle mainBundle]pathForResource:@"j1mall" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}



@end
