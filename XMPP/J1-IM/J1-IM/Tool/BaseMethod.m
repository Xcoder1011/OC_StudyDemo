//
//  BaseMethod.m
//  微信
//
//  Created by Think_lion on 15/6/16.
//  Copyright (c) 2015年 Think_lion. All rights reserved.
//

#import "BaseMethod.h"
#import "MBProgressHUD+MJ.h"
//#import "UIImageView+WebCache.h"
//#import "Reachability.h"
//#import "AFNetworking.h"


@implementation BaseMethod


+(void)showMessage:(NSString *)message
{
    [MBProgressHUD showMessage:message];
   
}
+(void)showMessage:(NSString *)message toView:(UIView *)toView
{
    [MBProgressHUD showMessage:message toView:toView];
}
+(void)hide
{
    [MBProgressHUD hideHUD];
}
+(void)hideFormView:(UIView *)forView
{
    [MBProgressHUD hideHUDForView:forView];
}

+(void)showError:(NSString *)error
{
    [MBProgressHUD showError:error];
}
+(void)showError:(NSString *)error toView:(UIView *)toView
{
    [MBProgressHUD showError:error toView:toView];
}
+(void)showSuccess:(NSString *)success
{
    [MBProgressHUD showSuccess:success];
}
+(void)showSuccess:(NSString *)success toView:(UIView *)toView
{
    [MBProgressHUD showSuccess:success toView:toView];
}
//设置缓存图片
//+(void)setCurrentImageView:(UIImageView*)imageView urlWithStr:(NSURL*)url  placeholderImage:(UIImage*)placeholderImage
//{
//    [imageView sd_setImageWithURL:url placeholderImage:placeholderImage];
//}
//发生内存警告的时候清除内存图片
//+(void)clearImageWhenReceiveMemoryWarning
//{
//    //清楚内存中的图片
//    //停止下载图片
//    [[SDWebImageManager sharedManager] cancelAll];
//    //移除下载到内存中的图片
//    [[SDWebImageManager sharedManager].imageCache clearMemory];
//}


@end
