//
//  XmppRoomManager.h
//  J1-IM
//
//  Created by wushangkun on 16/1/25.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmppManager.h"


// ************************************* XmppRoomManager *************************************/

typedef void(^InviteFriendsBlock)(id);
typedef void(^UpdateDateBlock)(id);

@interface XmppRoomManager : NSObject <XMPPMUCDelegate,XMPPRoomDelegate,XMPPRoomStorage>
{
    XMPPMUC *muc;
}
//房间列表
@property (nonatomic,strong) NSMutableArray *roomList;

//用于记录出席列表
@property (nonatomic,strong) NSMutableDictionary *presentDic;

#pragma mark 群聊

+(XmppRoomManager *)sharedXmppRoomManager;

//创建一个房间
- (void)creatChatRoom:(NSString *)roomJid;
- (void)queryRooms;
- (void)queryRoomsInfo:(NSString *)roomJid;
- (void)inviteUser:(NSString *)jidStr toRoom:(XMPPRoom *)room withMessage:(NSString *)message;
- (void)joinInChatRoom:(NSString *)roomJid withPassword:(NSString *)password;
- (void)sendMessage:(NSString *)message inChatRoom:(NSString *)chatRoomJid;



//获取所有聊天室
-(void)searchAllXmppRoomBlock:(void(^)(NSMutableArray *))rooms;
//发送聊天室信息
-(void)sendRoomMessage:(NSString*)messageStr roomName:(NSString*)roomName;
//邀请他人进入聊天室
-(void)inviteUserJoinRoom:(XMPPRoom*)room WithUserName:(NSString*)userName;
//拒绝加入聊天室
-(void)rejectJoinRoom:(NSString*)roomJid;
//创建聊天室 b为成功加入聊天室以后
-(XMPPRoom*)xmppRoomCreateRoomName:(NSString *)roomName nickName:(NSString *)nickName MessageBlock:(void(^)(NSDictionary*))a presentBlock:(void(^)(NSDictionary*))b;

// 离开房间
-(void)xmppLeaveRoom:(XMPPRoom*)room;

//修改房间名称 注！必须是主持人才有此权限
-(void)configRoom:(XMPPRoom*)room roomConfigForm:(NSXMLElement*)roomConfigForm;

//查找特定房间配置
-(void)fetchRoomName:(NSString*)roomName FetchRoomBlock:(void(^)(NSDictionary*))fetchRoomConfig;



//接收按照搜索条件返回的房间jid和房间名称
@property (nonatomic ,copy) void(^RoomsName)(NSMutableArray *);
//接收群聊消息
@property (nonatomic ,copy) void(^GroupMessage)(NSDictionary *);
//用于返回出席列表，谁进入谁退出
@property (nonatomic ,copy) void(^GroupPresent)(NSDictionary *);
//外部在退出当前界面时候需要修改该nowRoomjid为空
@property(nonatomic, copy) NSString *nowRoomJid;
//返回查找的房间信息
@property (nonatomic ,copy) void(^FetchRoom)(NSDictionary *);
//邀请朋友的Block
@property (nonatomic,copy) InviteFriendsBlock inviteFriendsBlock ;

@property (nonatomic,copy) UpdateDateBlock updateDateBlock;


@end
