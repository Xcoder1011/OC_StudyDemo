//
//  UIDevice+Common.m
//  HZ
//
//  Created by huazi on 14-8-5.
//  Copyright (c) 2014年 HZ. All rights reserved.
//

#import "UIDevice+Common.h"
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iOS7  ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define iOS8  ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
@implementation UIDevice (Common)

- (BOOL)isIOS7
{
    return iOS7;
}

- (BOOL) isIphone5
{
    return iPhone5;
}
- (BOOL) isIOS8
{
    return iOS8;
}
- (BOOL) isIphone4
{
    return iPhone4;
}
@end
