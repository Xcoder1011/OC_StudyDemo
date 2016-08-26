//
//  NineViewController.m
//  WebView-JS
//
//  Created by KUN on 16/8/26.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "NineViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface NineViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation NineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    //加载本地的html
    NSString *htmlPath = [[NSBundle mainBundle]pathForResource:@"Nine" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlStr = request.URL.absoluteString;
    NSLog(@"urlStr = %@",urlStr);
    if ([urlStr rangeOfString:@"ios://"].location != NSNotFound) {
        
        NSArray *strArr = [urlStr componentsSeparatedByString:@"//"];
        
        NSString *selectName = [strArr objectAtIndex:1];
        
        SEL selector = NSSelectorFromString(selectName);

        if ([self respondsToSelector:selector]) {
             // - Project - Build Settings - ENABLE_STRICT_OBJC_MSGSEND  将其设置为 NO
            objc_msgSend(self,selector);
        }
    }
    
    return YES;
}

-(void)openCamera{
    NSLog(@"打开相机");
}
-(void)openPhoto{
    NSLog(@"打开相册");
}
-(void)DetectionNet{
    NSLog(@"检测网络");
}
-(void)reloadHtml{
    NSLog(@"刷新网页");
}
-(void)openAddressBook{
    NSLog(@"获取通讯录");
}
-(void)Log{
    NSLog(@"Test log ...");
}




@end
