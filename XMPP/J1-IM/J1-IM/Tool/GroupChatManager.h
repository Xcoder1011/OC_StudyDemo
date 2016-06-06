//
//  GroupChatManager.h
//  J1-IM
//
//  Created by wushangkun on 16/1/26.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

// ************************************* 聊天室功能操作 *************************************/
@class ChatRoom;
@class ChatRoomMember;

typedef void(^InviteFriendsBlock)(id);
typedef void(^UpdateDateBlock)(id);

@interface GroupChatManager : NSObject <XMPPStreamDelegate,XMPPMUCDelegate,XMPPRoomStorage,XMPPRoomDelegate>
{
    NSMutableDictionary *_chatRoomDict;
    //服务列表
    NSMutableArray *_chatRoomServices;
    
    XMPPMUC *muc;
}

@property (nonatomic ,readonly) NSDictionary *chatRoomDict;
@property (nonatomic ,readonly) NSArray *chatRoomServices;

//邀请朋友的Block
@property (nonatomic,copy) InviteFriendsBlock inviteFriendsBlock ;

@property (nonatomic,copy) UpdateDateBlock updateDateBlock;


+(GroupChatManager *)sharedGroupManager;

//发送http://jabber.org/protocol/disco#info
-(void)queryInfoWithJID:(NSString*)jid;      //MUC
//发送http://jabber.org/protocol/disco#items
-(void)queryItemsWithJID:(NSString *)jid;    //Services

//发现MUC服务
-(void)queryMCU;
//查询服务列表
-(void)queryServices;
//查询服务下的房间列表
-(void)queryChatRoomsInService:(NSString*)service;
//MCU方法
-(void)queryRoomsWithMCU;

//查询一个房间的信息
-(void)queryChatRoomInfo:(NSString*)roomJid;
//查询房间的条目
-(void)queryChatRoomItems:(NSString*)roomJid;
//进入一个房间
-(void)joinInChatRoom:(NSString*)roomJid withPassword:(NSString*)password;
//退出一个房间
-(void)quitChatRoom:(NSString*)roomJid;
//返回一个房间,房间总是存在
-(ChatRoom*)returnChatRoom:(NSString*)roomJid;
//更新房间成员信息
-(void)updateGroupRoomMember:(ChatRoomMember*)chatRoomMember;
//创建一个房间
- (void)creatChatRoom:(NSString *)roomJid withPassword:(NSString *)password;
//获得某个房间内的某个成员
-(ChatRoomMember*)returnMemberWith:(NSString*)jid
                  inChatRoom:(NSString*)chatRoomJid;
/*
<message
from='crone1@shakespeare.lit/desktop'
to='darkcave@chat.shakespeare.lit'>
<x xmlns='http://jabber.org/protocol/muc#user'>
<invite to='hecate@shakespeare.lit'>
<reason>
Hey Hecate, this is the place for all good witches!
</reason>
</invite>
</x>
</message>
*/
//邀请一个成员进入房间
-(void)inviteMember:(NSString*)memberJid
      toChatRoomJid:(NSString*)chatRoomJid
             reason:(NSString*)reason
       withPassword:(NSString*)password;

//邀请一个成员进入房间ROOM
- (void)inviteUser:(NSString *)jidStr toRoom:(XMPPRoom *)room withMessage:(NSString *)message;

@end



// ************************************* 聊天室的一个成员 *************************************/
///聊天室的一个成员
@interface ChatRoomMember : NSObject{
}
@property (nonatomic,copy) NSString* chatRoomJid;
@property (nonatomic,copy) NSString* chatRoomMembername;
@property (nonatomic,copy) NSString* chatRoomMemberJid;
@property (nonatomic,copy) NSString* affiliation;
@property (nonatomic,copy) NSString* role;
@property (nonatomic,copy) NSString* show;
@property (nonatomic,copy) NSString* status;
///修改名字时的新名字
@property (nonatomic,copy) NSString* nick;
-(id)initWithPresence:(XMPPPresence*)presence;
@end

// ************************************* 聊天室房间信息的各个字段 *************************************/
///聊天室房间信息的各个字段
@interface ChatRoomInfoField:NSObject{
}
@property (nonatomic,copy) NSString* var;
@property (nonatomic,copy) NSString* label;
@property (nonatomic,copy) NSString* value;
-(id)initWithVar:(NSString*)var
           label:(NSString*)label
           value:(NSString*)value;
@end

// ************************************* 聊天室房间信息 *************************************/
///聊天室房间信息
#define ChatRoomRefreshRoomsNotification @"ChatRoomRefreshRoomsNotification" ///刷新房间列表时发出的通知
@interface ChatRoomInfo:NSObject{
    NSMutableArray* _features;
    NSMutableDictionary* _fields;
}
@property (nonatomic,readonly) NSArray* features;
@property (nonatomic,readonly) NSDictionary* fields;
@property (nonatomic,copy) NSString* category;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* type;
@property (nonatomic,readonly) BOOL public;
@property (nonatomic,readonly) BOOL needPassword;
@property (nonatomic,readonly) BOOL membersOnly;
@property (nonatomic,readonly) NSString* roomDescription;
@property (nonatomic,readonly) NSString* subject;
@property (nonatomic,readonly) int occupants;
@property (nonatomic,readonly) NSString* creationdate;
-(id)initWithIq:(XMPPIQ*)iq;
@end

// ************************************* 聊天室房间 *************************************/
///聊天室房间
@interface ChatRoom : NSObject{
    NSMutableDictionary* _memberListDict;
}
///chatRoomMemberJid and ChatRoomMember
@property (nonatomic,readonly) NSDictionary* memberListDict;
@property (nonatomic,copy) NSString* chatRoomJid;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,strong) XMPPRoom* xmpproom;

///房间信息
@property (nonatomic,retain) ChatRoomInfo* chatRoomInfo;
-(id)initWithChatRoomJid:(NSString*)chatRoomJid;
///更新房间成员信息
-(void)updateChatRoomMember:(ChatRoomMember*)chatRoomMember;
///获取房间内的一个成员
-(ChatRoomMember*)chatRoomMember:(NSString*)chatRoomMemberJid;
@end

