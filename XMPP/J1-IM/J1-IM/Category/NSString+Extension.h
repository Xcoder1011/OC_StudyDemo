//
//  NSString+Extension.h
//  J1-IM
//
//  Created by liang on 16/1/27.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
// 返回用户和好友的关系状态
+ (NSString *)relationshipWithFriend:(NSString *)subscription;
@end
