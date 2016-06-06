//
//  UIDevice+Common.h
//  HZ
//
//  Created by huazi on 14-8-5.
//  Copyright (c) 2014年 HZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Common)
/// 判断是否为iphone5的屏幕
- (BOOL) isIphone5;
- (BOOL) isIphone4;
/// 系统是否为ios7以上
- (BOOL) isIOS7;
- (BOOL) isIOS8;

@end
