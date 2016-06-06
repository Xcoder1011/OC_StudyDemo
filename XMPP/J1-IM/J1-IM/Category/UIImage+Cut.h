//
//  UIImage+Cut.h
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ImageScale 0.2
#define LogoImageMargin 5

@interface UIImage (Cut)

+(UIImage *)resizedImage:(NSString *)name;
+(UIImage *)resizedImage:(NSString *)name left:(CGFloat)left top:(CGFloat)top;


//截屏方法
+(instancetype)renderView:(UIView *)renderView;
//图片加水印
+(instancetype)waterWithBgName:(NSString *)bg waterLogo:(NSString *)water;
//裁剪图片为圆行
+(instancetype)clipWithImageName:(NSString*)name bordersW:(CGFloat)bordersW borderColor:(UIColor *)borderColor;

@end
