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
//#import "XmppManager.h"
#import "HYXMPPManager.h"
#import "UIView+Frame.h"

#import "HYXMPPConfig.h"


// 偏好设置
#define MyDefaults [NSUserDefaults standardUserDefaults]
// 弱引用
#define HYWeakSelf __weak typeof(self) weakSelf = self;

#define HYWeakObj(o) autoreleasepool{} __weak typeof(o)  Weak##o = o;
#define HYStrongObj(o) autoreleasepool{} __strong typeof(o) o = Weak##o;

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])


#ifndef __OPTIMIZE__
//这里执行的是debug模式下
#else
//这里执行的是release模式下
#endif



#if defined (__i386__) || defined (__x86_64__)
//模拟器下执行
#else
//真机下执行
#endif

//if (__IPHONE_OS_VERSION_MAX_ALLOWED == __IPHONE_9_0) {
//            //如果当前SDK版本为9.0是执行这里的代码
//        }else{
//                //否则执行这里
//            }

//#ifdef ****
////代码1
////如果标识符****已被#define命令定义过，则对代码1进行编译，否则对代码2进行编译。
//else
////代码2
//#endif


#endif /* ClassesPre_h */
