//
//  HYNavigationController.h
//
//
//  Created by xiaoma on 15/9/2.
//  Copyright (c) 2015年 xiaoma. All rights reserved.
//

#import "HYTabBarController.h"
#import "ContactorViewController.h"
#import "MineViewController.h"
#import "MessageViewController.h"
#import "DiscoveryViewController.h"
#import "HYTabBar.h"
#import "HYNavigationController.h"

@interface HYTabBarController ()

@end

@implementation HYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置item属性
    [self setupItem];
    
    // 添加所有的子控制器
    [self setupChildVcs];
    
    // 处理TabBar
    [self setupTabBar];
}

/**
 * 处理TabBar
 */
- (void)setupTabBar
{
    [self setValue:[[HYTabBar alloc] init] forKeyPath:@"tabBar"];
}

/**
 * 添加所有的子控制器
 */
- (void)setupChildVcs
{
    [self setupChildVc:[[MessageViewController alloc] init] title:@"消息" image:@"tabbar_mainframe" selectedImage:@"tabbar_mainframeHL"];
    
    [self setupChildVc:[[ContactorViewController alloc] init] title:@"联系人" image:@"tabbar_contacts" selectedImage:@"tabbar_contactsHL"];
    
    [self setupChildVc:[[DiscoveryViewController alloc] init] title:@"发现" image:@"tabbar_discover" selectedImage:@"tabbar_discoverHL"];
    
    [self setupChildVc:[[MineViewController alloc] init] title:@"我" image:@"tabbar_me" selectedImage:@"tabbar_meHL"];
}

/**
 * 添加一个子控制器
 * @param title 文字
 * @param image 图片
 * @param selectedImage 选中时的图片
 */
- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 包装一个导航控制器
    HYNavigationController *nav = [[HYNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
    
    // 设置子控制器的tabBarItem
    nav.tabBarItem.title = title;
    nav.tabBarItem.image = [UIImage imageNamed:image];
    nav.tabBarItem.selectedImage = [UIImage imageNamed:selectedImage];
//    [nav.tabBarItem setBadgeValue:@"20"];
}

/**
 * 设置item属性
 */
- (void)setupItem
{
    // UIControlStateNormal状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    // 文字颜色
    normalAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    // 文字大小
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    
    // UIControlStateSelected状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    // 文字颜色
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor greenColor];
    
    // 统一给所有的UITabBarItem设置文字属性
    // 只有后面带有UI_APPEARANCE_SELECTOR的属性或方法, 才可以通过appearance对象来统一设置
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
}

@end
