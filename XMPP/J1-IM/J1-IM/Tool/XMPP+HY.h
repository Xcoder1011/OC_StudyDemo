//
//  XMPP+HY.h
//  J1-IM
//
//  Created by wushangkun on 16/1/26.
//  Copyright © 2016年 J1. All rights reserved.
//



#import "XMPPPresence.h"
#import "XMPPIQ.h"
#import "XMPPMessage.h"

@interface XMPPPresence (HY)
///是否来自聊天室的状态
-(BOOL)isChatRoomPresence;

@end


@interface XMPPIQ(HY)
///是否是获取联系人的请求
-(BOOL)isRosterQuery;
///是否是房间列表请求
-(BOOL)isChatRoomItems;
///是否是房间信息查询
-(BOOL)isChatRoomInfo;
@end


@interface XMPPMessage(HY)
///是否是来自房间邀请
-(BOOL)isChatRoomInvite;
@end