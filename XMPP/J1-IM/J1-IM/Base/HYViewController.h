//
//  HYViewController.h
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYViewController : UIViewController
/**
 *  设置导航条的leftiterm
 *
 *  @param str   str description
 *  @param image image description
 */
- (void)setNavLeftItemWith:(NSString *)str andImage:(UIImage *)image;

/**
 *  设置导航的rightitem
 *
 *  @param str   str description
 *  @param image image description
 */
- (void)setNavRightItemWith:(NSString *)str andImage:(UIImage *)image;

- (void)setNavRightItems:(NSArray *)arrays;

- (void)HYBackClick:(id) sender;

- (void)rightItemClick:(id)sender;

- (void)leftItemClick:(id)sender;

- (void)rightItem2Click:(id)sender;
@end
