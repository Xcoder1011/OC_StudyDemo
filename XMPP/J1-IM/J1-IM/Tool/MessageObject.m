//
//  MessageObject.m
//  J1-IM
//
//  Created by wushangkun on 16/1/25.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "MessageObject.h"
#import "HYDatabase.h"

@implementation MessageObject

//数据库增删改查
+(BOOL)save:(MessageObject*)aMessage
{
    HYDatabase *db = [HYDatabase sharedManager];
    if (!db.isDBopen) {
        NSLog(@"数据库打开失败");
        return NO;
    }
    
    FMResultSet *call = [db userQueryData:SELECT_J1MESSAGE_SQL objects:@[aMessage.messageFrom,aMessage.messageTo]];
    BOOL isData=NO;
    while ([call next]) {
        isData=YES;
    }
    if (!isData) {
        call = [db userQueryData:SELECT_J1MESSAGE_SQL objects:@[aMessage.messageFrom,aMessage.messageTo]]; //反查一次
        while ([call next]) {
            isData = YES;
        }
    }
    
    if (!isData) {
//        //如果表内没有数据，就插入数据
//        [db insertOrDeleteData:INSERT_J1MESSAGE_SQL objects:@[aMessage.messageFrom,aMessage.messageTo,aMessage.messageContent,aMessage.messageDate,aMessage.messageType]];
    }else{
         //如果表内有数据，就更新数据
        [db insertOrDeleteData:UPDATE_J1MESSAGE_SQL objects:@[aMessage.messageContent,aMessage.messageDate,aMessage.messageTo,aMessage.messageFrom]];
    }
    
    return isData;

}

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex
{
    return nil;

}

@end
