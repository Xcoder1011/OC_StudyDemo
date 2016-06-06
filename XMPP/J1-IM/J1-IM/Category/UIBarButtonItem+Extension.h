//
//  UIBarButtonItem+LJExtension.h
//  test
//
//  Created by liang on 15/9/1.
//  Copyright (c) 2015年 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)
+ (instancetype)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action;
@end
