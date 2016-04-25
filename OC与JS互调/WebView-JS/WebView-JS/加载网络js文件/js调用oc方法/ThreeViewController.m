//
//  ThreeViewController.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/19.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "ThreeViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

// 需要遵守JSExport协议
@protocol MyJSExportDelegate <JSExport>

//  可以用JSExportAs 在 JavaScript 中有一个比较短的名字
JSExportAs(caculateFactorial,/** showCaculateResultWithNumber 作为js方法的别名 */
           -(void)showCaculateResultWithNumber:(NSNumber *)number
           );

// 声明一个继承JSExport的协议,协议中声明供JS使用的OC的方法
-(void)pushToViewControllerWithName:(NSString *)controllerName;

@end


@interface ThreeViewController () <UIWebViewDelegate,MyJSExportDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) JSContext *context;

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"js调用oc";
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    //加载本地的html    
    NSString *htmlPath = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:@"Three.html"];
    NSURL *url = [NSURL URLWithString:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];

}


#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //  html的title设置为导航栏的title
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    // 禁用 页面元素选择
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用 长按弹出ActionSheet
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];

    // 1. 首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.context = context;
    
    // 1.1 打印异常
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue){
        context.exception = exceptionValue;
        NSLog(@"打印异常:%@",exceptionValue);
    };
    
    // 1.2 测试log
    // 以 block 形式关联 JavaScript
    self.context[@"log"] = ^(NSString *logStr){
        NSLog(@"测试log:%@",logStr);
    };
    
    // 1.3 计算阶乘
    // 以 JSExport 协议关联 native方法
    self.context[@"native"] = self;
    
    // 1.4 oc弹框
    self.context[@"alert"] = ^(NSString * str){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    };

    // 1.5 多参数调用
    self.context[@"mutiParams"] = ^(NSString *a,NSString *b,NSString *c){
        NSLog(@"三个参数分别是:%@,%@,%@",a,b,c);
    };
}


#pragma mark -- 1.6 push到某个控制器
-(void)pushToViewControllerWithName:(NSString *)controllerName{

    Class second = NSClassFromString(controllerName);
    id secondVC = [[second alloc]init];
    UIViewController *secCtrl = secondVC;
    [self.navigationController pushViewController:secCtrl animated:YES];
}

#pragma mark -- 1.3 计算阶乘
-(void)showCaculateResultWithNumber:(NSNumber *)number{
    NSLog(@"number = %@",number);
    NSNumber *result  = [self caculateFactorialWithNum:number];
    NSLog(@"result = %@",result);
    //计算的结果显示出来
    [self.context[@"showResult"] callWithArguments:@[result]];
}

-(NSNumber *)caculateFactorialWithNum:(NSNumber *)number{
    NSInteger i = [number integerValue];
    if (i < 0) {
        return [NSNumber numberWithInteger:0];
    }
    if (i == 0) {
        return [NSNumber numberWithInteger:1];
    }
    NSInteger r = (i*[(NSNumber *)[self caculateFactorialWithNum:[NSNumber numberWithInteger:(i-1)]]integerValue]);
    return [NSNumber numberWithInteger:r];
}



@end
