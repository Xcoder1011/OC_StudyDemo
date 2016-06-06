//
//  TheMessage.h
//  J1-IM
//
//  Created by liang on 16/2/4.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TheMessage : NSObject
// 消息的标题
@property (nonatomic, copy) NSString *messageTitle;
// 消息的正文
@property (nonatomic, copy) NSString *messageText;

@end
