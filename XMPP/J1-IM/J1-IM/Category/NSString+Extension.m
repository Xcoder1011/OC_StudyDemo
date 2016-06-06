//
//  NSString+Extension.m
//  J1-IM
//
//  Created by liang on 16/1/27.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
// 返回用户和好友的关系状态
+ (NSString *)relationshipWithFriend:(NSString *)subscription {
    if ([subscription isEqualToString:@"to"]) {
        return @"我关注对方";
    }else if ([subscription isEqualToString:@"from"]){
        return @"对方关注我";
    }else if ([subscription isEqualToString:@"both"]){
        return @"互粉";
    }else if ([subscription isEqualToString:@"none"]){
        return @"未确认";
    }else{
        return @"未知";
    }
}
@end
