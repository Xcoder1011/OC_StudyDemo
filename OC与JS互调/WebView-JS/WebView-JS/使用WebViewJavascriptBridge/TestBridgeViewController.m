//
//  TestBridgeViewController.m
//  WebView-JS
//
//  Created by KUN on 17/3/23.
//  Copyright © 2017年 wushangkun. All rights reserved.
//

#import "TestBridgeViewController.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@interface TestBridgeViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong , nonatomic) WebViewJavascriptBridge *bridge;


@end

@implementation TestBridgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.加载本地的html
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testBridge" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:filePath];
    [self.webView loadHTMLString:appHtml baseURL:baseUrl];
    
    // 2.开启日志
    [WebViewJavascriptBridge enableLogging];
    
    // 3.给 webview 架桥
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
    //  ------------------------------ 4.1  JS调用OC的方法 ------------------------------
    
    // js调用本地的打开相册
    [self.bridge registerHandler:@"openPhoto" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"传过来的参数 dataParam = %@",data);  // 'count':'10张'
        /*
         
         dataParam = {
                        count = "10\U5f20";
                     }
         
         */
        UIImagePickerController *imageVC = [[UIImagePickerController alloc] init];
        imageVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imageVC animated:YES completion:nil];
        responseCallback(@"结果返回给js");

    }];
    
    
    
    
    // js调用本地 导航栏变颜色
    [self.bridge registerHandler:@"changeNavColor" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"传过来的参数 dataParam = %@",data);  // 'color':'RedColor'
        /*
         
         dataParam = {
                        color = RedColor;
                     }
         
         */
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        responseCallback(@"导航栏颜色已经改变");

    }];
  
}

- (IBAction)getUserInfomation:(UIButton *)sender {
    
    [self.bridge callHandler:@"getUserInfo" data:@{@"new":@"dtas"} responseCallback:^(id responseData) {
        //
    }];
}


- (IBAction)insertImage:(UIButton *)sender {
    
    [self.bridge callHandler:@"insertImgToWebPage" data:@{@"url":@"http://zxpic.gtimg.com/infonew/0/wechat_pics_-214270.jpg/168"} responseCallback:^(id responseData) {
        //
    }];
}


- (IBAction)pushToNext:(UIButton *)sender {
    [self.bridge callHandler:@"pushToNewWebSite" data:@{@"url":@"https://www.baidu.com/"} responseCallback:^(id responseData) {
        //
    }];
}

@end
