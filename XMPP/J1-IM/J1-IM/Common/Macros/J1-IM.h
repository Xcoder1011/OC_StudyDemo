//
//  J1-IM.h
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#ifndef J1_IM_h
#define J1_IM_h

//服务器的ip地址 （域名也行）
#define ServerIP @"172.16.90.52"
//服务器的端口号
#define ServerPort 5222
//服务器的域名
#define ServerName @"127.0.0.1"

//区别单聊和群聊的表示
#define SOLECHAT @"[1]"
#define GROUPCHAT @"[2]"

//群聊需要设置以下节点名称
//默认
//#define GROUND @"conference"
#define GROUND @"room11"
#define GROUNDROOMCONFIG @"roomconfig"
#define ZIYUANMING @"IOS"
#define FRIENDS_TYPE @"friends_type"

//创建群时候保存群昵称和群描述
#define GROUNDNAME @"groundname"
#define GROUNDDES  @"grounddes"

//用户信息
#define kXMPPmyJID @"myXmppJid"
#define kXMPPmyPassword @"myXmppPassword"
#define kXMPPNewMsgNotifaction @"xmppNewMsgNotifaction"
#define kXMPPFriendType @"FriendType"
#define weiduMESSAGE @"weiduxiaoxi"

//发送消息的标记
#define MESSAGE_STR @"[1]"
#define MESSAGE_VOICE @"[2]"
#define MESSAGE_IMAGESTR @"[3]"
#define MESSAGE_BIGIMAGESTR @"[4]"


#endif /* J1_IM_h */
