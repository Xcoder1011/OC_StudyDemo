//
//  Roster.h
//  J1-IM
//
//  Created by wushangkun on 16/1/29.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#pragma mark - RosterMember
#define RosterMemberPresenceShowChat @"chat" ///空闲
#define RosterMemberPresenceShowAway @"away" ///离开
#define RosterMemberPresenceShowDnd @"dnd" ///请勿打扰
#define RosterUpdateNotification @"RosterUpdateNotification" ///更新联系人列表时通知

@interface RosterMember : NSObject{

}
@property (nonatomic,copy) NSString* jid;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* availableStr;
@property (nonatomic,copy) NSString* status;
@property (nonatomic,copy) NSString* show;
@property (nonatomic,copy) NSString* group;
@property (nonatomic,copy) NSString* subscription;
@property (nonatomic,readonly) BOOL available;
///还未读的消息数量
@property (nonatomic,assign) int unread_total;
///正在邀请订阅我中
@property (nonatomic,assign) BOOL want_to_subscribe_me;
-(id)initWithPresence:(XMPPPresence*)presence;
///从iq query roster 的element来创建
-(id)initWithRosterElement:(NSXMLElement*)element;

@end




@interface Roster : NSObject<XMPPStreamDelegate> {

}

///好友列表
@property (nonatomic,retain) NSMutableDictionary* memberListDict;
///联系人数量
@property (nonatomic,readonly) NSInteger memberTotalNum;

+(Roster *)sharedRoster;
///更新一个联系人信息
-(RosterMember*)updateMemberInfo:(RosterMember*)member;
///获取一个联系人信息
-(RosterMember*)memberByJid:(NSString*)jid;
///获取一个联系人信息
-(RosterMember*)memberAtIndex:(int)index;
///当前登录的用户
-(RosterMember*)currentLoginMember;
///获取联系人的列表
-(void)queryRosterList;


///增加未读消息数量
-(RosterMember*)increaseUnreadMessageNumForJid:(NSString*)jid;
///清空未读消息数量
-(RosterMember*)clearUnreadMessageNumForJid:(NSString*)jid;



@end
