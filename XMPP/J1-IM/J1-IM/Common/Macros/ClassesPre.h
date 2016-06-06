//
//  ClassesPre.h
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#ifndef ClassesPre_h
#define ClassesPre_h

#import "NSData+Base64.h"
#import "Toast+UIView.h"
#import "UIColor+Common.h"
#import "UIDevice+Common.h"
#import "UIImage+Size.h"
#import "UIImage+Cut.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+MJ.h"
#import "Singleton.h"
#import "MBProgressHUD+MJ.h"
#import "BaseMethod.h"
#import "Const.h"
#import "UserOperation.h"
#import "NSString+Extension.h"
#import "XmppManager.h"
#import "UIView+Frame.h"


// 偏好设置
#define MyDefaults [NSUserDefaults standardUserDefaults]
// 弱引用
#define HYWeakSelf __weak typeof(self) weakSelf = self;

#define HYWeakObj(o) autoreleasepool{} __weak typeof(o)  Weak##o = o;
#define HYStrongObj(o) autoreleasepool{} __strong typeof(o) o = Weak##o;

#endif /* ClassesPre_h */
