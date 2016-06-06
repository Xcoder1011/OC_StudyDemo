//
//  MessageObject.h
//  J1-IM
//
//  Created by wushangkun on 16/1/25.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageObject : NSObject

//来自哪里
@property (nonatomic,copy) NSString *messageFrom;
//发送给谁
@property (nonatomic,copy) NSString *messageTo;
//内容
@property (nonatomic,copy) NSString *messageContent;
//时间
@property (nonatomic,retain) NSDate *messageDate;
//类型
//@property (nonatomic,copy) NSString *messageType;

//数据库增删改查
+(BOOL)save:(MessageObject*)aMessage;

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex;

@end
