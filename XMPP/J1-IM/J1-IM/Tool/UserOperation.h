//
//  UserOperation.h
//  J1-IM
//
//  Created by liang on 16/1/23.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
//通过单例来保存用户基本信息
@interface UserOperation : NSObject
SingletonH(user);
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *hostUrl;
@property (nonatomic,assign) BOOL loginStatus;

@property (nonatomic, strong) NSString *registerUser;
@property (nonatomic, strong) NSString *registerPwd;
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString * joinRoomName;

@end
