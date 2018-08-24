//
//  WKWebViewMessageHandlerController.m
//  WebView-JS
//
//  Created by KUN on 2017/10/12.
//  Copyright © 2017年 wushangkun. All rights reserved.
//

#import "WKWebViewMessageHandlerController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewMessageHandlerController () <WKUIDelegate,WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) WKWebViewConfiguration *webConfig;
@property(nonatomic, strong) UIProgressView *progressView;

@end

@implementation WKWebViewMessageHandlerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self.navigationController.navigationBar addSubview:self.progressView];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    // 1.加载本地的html
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testBridge" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:filePath];
    [self.webView loadHTMLString:appHtml baseURL:baseUrl];
  
}


- (IBAction)getUserInfomation:(UIButton *)sender {
    
    // OC 调用 JS
   
}

- (IBAction)insertImage:(UIButton *)sender {
  
}


- (IBAction)pushToNext:(UIButton *)sender {
 
}


- (void)setupUI
{
    [self.bottomView addSubview:self.webView];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.webView) {
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            
            if(self.webView.estimatedProgress >= 1.0f) {
                
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0f animated:NO];
                }];
                
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            self.title = self.webView.title;
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.webView.frame = self.bottomView.bounds;
}


#pragma mark - WKNavigationDelegate

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - setters and getters

- (WKWebView *)webView
{
    if (!_webView)
    {
        _webView = [[WKWebView alloc] initWithFrame:self.bottomView.bounds configuration:self.webConfig];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.multipleTouchEnabled = YES;
        _webView.autoresizesSubviews = YES;
    }
    return _webView;
}


- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        CGFloat progressBarHeight = 3.0f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
        _progressView.tintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor lightGrayColor];
        self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    }
    return _progressView;
}

- (WKWebViewConfiguration *)webConfig
{
    if (!_webConfig) {
        
        // 创建并配置WKWebView的相关参数
        _webConfig = [[WKWebViewConfiguration alloc] init];
        _webConfig.allowsInlineMediaPlayback = YES;
        
        // 通过 JS 与 webView 内容交互
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        // 设置字体大小(最小的字体大小)
        // preference.minimumFontSize = 30.0;
        // 设置偏好设置对象
        _webConfig.preferences = preference;
        
        // 自适应屏幕宽度js
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [userContentController addUserScript:wkUScript];
        _webConfig.userContentController = userContentController;
        // 是否支持 JavaScript
        _webConfig.preferences.javaScriptEnabled = YES;
        // 不通过用户交互，是否可以打开窗口
        _webConfig.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    }
    return _webConfig;
}



- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    
    [self.webView removeFromSuperview];
    [self.progressView removeFromSuperview];
    
    self.webView = nil;
    self.webConfig = nil;
}


@end
