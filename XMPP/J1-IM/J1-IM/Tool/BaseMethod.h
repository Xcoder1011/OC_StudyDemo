//
//  BaseMethod.h
//  微信
//
//  Created by Think_lion on 15/6/16.
//  Copyright (c) 2015年 Think_lion. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseMethod : NSObject

//显示信息
+(void)showMessage:(NSString*)message;
+(void)showMessage:(NSString*)message toView:(UIView*)toView;
+(void)hideFormView:(UIView*)forView;
+(void)hide;
//显示正确错误
+(void)showError:(NSString*)error;
+(void)showError:(NSString*)error toView:(UIView*)toView;
+(void)showSuccess:(NSString*)success;
+(void)showSuccess:(NSString*)success toView:(UIView*)toView;

//设置缓存图片
//+(void)setCurrentImageView:(UIImageView*)imageView urlWithStr:(NSURL*)url  placeholderImage:(UIImage*)placeholderImage;
//发生内存警告的时候清除内存图片
//+(void)clearImageWhenReceiveMemoryWarning;


@end
