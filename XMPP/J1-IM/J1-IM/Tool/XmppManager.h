//
//  XmppManage.h
//  J1-IM
//
//  Created by wushangkun on 16/1/23.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

#define XMPPSTREAM  [XmppManager sharedxmppManager].xmppStream


@interface XmppManager : NSObject{
    XMPPStream *_xmppStream;
}

SingletonH(xmppManager)

///当前的登录用户id
@property (nonatomic,copy) NSString* jidName;
@property (nonatomic,copy) NSString* userName;


/** 存储失败的回调 */
@property(nonatomic,strong) void (^failed) (NSString * errorMessage);

// xmppstream  xmpp流
@property (nonatomic,strong) XMPPStream *xmppStream;
// 电子名片
//@property (nonatomic,strong,readonly) XMPPvCardTempModule *vCard;
// 头像模块
//@property (nonatomic,strong,readonly) XMPPvCardAvatarModule *avatar;
// 添加花名册模块
@property (nonatomic,strong) XMPPRoster *xmppRoster;

@property (nonatomic,strong) XMPPRoomCoreDataStorage *roomCoreData;

@property (nonatomic,strong) XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;
// 聊天模块
@property (nonatomic,strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
/** 消息归档 */
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;
//如果是YES就是注册的方法
@property (nonatomic, assign, getter=isRegisterOperation) BOOL isRegisterOperation;


// 连接的方法(存储失败的回调)
- (void)connect:(void (^)(NSString *errorMessage))failed;
// 断开连接的方法
- (void)disconnect;
// 登出
- (void)logout;
// 销毁xmppStream
- (void)teardownXmppStream;

// 发送消息给朋友
- (void)sendMessage:(NSString *)message toUser:(XMPPJID *)userJID;
// 通过好友姓名添加好友
- (void)addFriendWithFriendName:(NSString *)friendName;
@end
