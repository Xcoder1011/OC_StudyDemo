//
//  GroupChatManager.m
//  J1-IM
//
//  Created by wushangkun on 16/1/26.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "GroupChatManager.h"
#import "XmppManager.h"
#import "XMPP+HY.h"
#import "Message.h"

// ************************************* 聊天室功能操作 *************************************/
@interface GroupChatManager (){
}
@property (nonatomic ,readonly) XmppManager *manager;
@end


@implementation GroupChatManager

static GroupChatManager* _sharedGroupChatManager;

+(GroupChatManager *)sharedGroupManager
{
    if (!_sharedGroupChatManager) {
        _sharedGroupChatManager = [[super allocWithZone:NULL]init];
        [_sharedGroupChatManager setup];
    }
    return _sharedGroupChatManager;
}

-(void)setup {
    muc = [[XMPPMUC alloc]init];
    [muc activate:[XmppManager sharedxmppManager].xmppStream];
    [muc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    _chatRoomDict = [[NSMutableDictionary alloc]init];
    _chatRoomServices = [[NSMutableArray alloc]init];
}

-(XmppManager *)manager{
    return [XmppManager sharedxmppManager];
}
-(NSDictionary *)chatRoomDict {
    return _chatRoomDict;
}

#pragma mark - MCU
//发送http://jabber.org/protocol/disco#info
-(void)queryInfoWithJID:(NSString*)jid
{
    XMPPIQ* iq=[XMPPIQ iqWithType:@"get"];
    //[iq addAttributeWithName:@"from" stringValue:[UserOperation shareduser].jid];

    [iq addAttributeWithName:@"from" stringValue:self.manager.jidName];
    [iq addAttributeWithName:@"id" stringValue:@"disco-1"];
    [iq addAttributeWithName:@"to" stringValue:jid];
    NSXMLElement* element_query=[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    [iq addChild:element_query];
    [self.manager.xmppStream sendElement:iq];
}

#pragma mark - Services
//发送http://jabber.org/protocol/disco#items
-(void)queryItemsWithJID:(NSString *)jid
{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    //[iq addAttributeWithName:@"from" stringValue:[UserOperation shareduser].jid];
    [iq addAttributeWithName:@"from" stringValue:self.manager.jidName];
    [iq addAttributeWithName:@"id" stringValue:@"disco-3"];
    [iq addAttributeWithName:@"to" stringValue:jid];
    NSXMLElement* element_query=[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:element_query];
    NSLog(@"iq in Services is %@",iq);
    [self.manager.xmppStream sendElement:iq];
}

//发现MCU服务
-(void)queryMCU{
    [self queryInfoWithJID:self.manager.jidName];

    //[self queryInfoWithJID:[UserOperation shareduser].jid];
}

//查询服务列表
-(void)queryServices{
    [self queryItemsWithJID:[UserOperation shareduser].hostUrl];
}

//查询服务下的房间列表
-(void)queryChatRoomsInService:(NSString*)service{
    [self queryItemsWithJID:service];
}

//MCU方法
-(void)queryRoomsWithMCU{
    [muc discoverRoomsForServiceNamed:[NSString stringWithFormat:@"conference.%@",[UserOperation shareduser].hostUrl]];
   // [ muc discoverRoomsForServiceNamed:[NSString stringWithFormat:@"%@",[UserOperation shareduser].hostUrl]];

    NSLog(@"[UserOperation shareduser].hostUrl] = %@",[UserOperation shareduser].hostUrl);
    //[muc discoverServices];
}

//查询一个房间的信息
-(void)queryChatRoomInfo:(NSString*)roomJid{
    [self queryInfoWithJID:roomJid];
}

//查询房间的条目
-(void)queryChatRoomItems:(NSString*)roomJid{
    [self queryItemsWithJID:roomJid];
}

//进入一个房间
-(void)joinInChatRoom:(NSString *)roomJid withPassword:(NSString *)password{
    NSString* memberJid = [NSString stringWithFormat:@"%@/%@",roomJid,[UserOperation shareduser].username];
    XMPPPresence* presence=[XMPPPresence presence];
    //[presence addAttributeWithName:@"from" stringValue:[UserOperation shareduser].jid];
    [presence addAttributeWithName:@"from" stringValue:self.manager.jidName];
    [presence addAttributeWithName:@"to" stringValue:memberJid];
    NSXMLElement* element_x=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
    [presence addChild:element_x];
    if (password){
        NSXMLElement* elemnt_password=[NSXMLElement elementWithName:@"password"];
        [elemnt_password setStringValue:password];
        [element_x addChild:elemnt_password];
    }
    [self.manager.xmppStream sendElement:presence];
    /*
     <presence from="wushangkun@127.0.0.1" to="room2@conference.127.0.0.1/wushangkun"><x xmlns="http://jabber.org/protocol/muc"></x></presence>
     */
}

//退出一个房间
-(void)quitChatRoom:(NSString*)roomJid{
    NSString* memberJid = [NSString stringWithFormat:@"%@/%@",roomJid,[UserOperation shareduser].username];
    XMPPPresence* presence=[XMPPPresence presenceWithType:@"unavailable"];
    //[presence addAttributeWithName:@"from" stringValue:[UserOperation shareduser].jid];
    [presence addAttributeWithName:@"from" stringValue:self.manager.jidName];
    [presence addAttributeWithName:@"to" stringValue:memberJid];
    [self.manager.xmppStream sendElement:presence];
}

//返回一个房间,房间总是存在
-(ChatRoom*)returnChatRoom:(NSString*)roomJid{
 //   ChatRoom* chatRoom;
//    if (roomJid == nil) return chatRoom;
    ChatRoom* chatRoom = _chatRoomDict[roomJid];
//    XMPPJID *jid = [XMPPJID jidWithString:roomJid];
//    XMPPRoom *room = [[XMPPRoom alloc]initWithRoomStorage:[XmppManager sharedxmppManager].roomCoreData jid:jid];
//    chatRoom.xmpproom = room;
    if (!chatRoom) {
        chatRoom = [[ChatRoom alloc]initWithChatRoomJid:roomJid];
        _chatRoomDict[roomJid] = chatRoom;
    }
    _chatRoomDict[roomJid] = chatRoom;
    return chatRoom;
}

//更新房间成员信息
-(void)updateGroupRoomMember:(ChatRoomMember*)chatRoomMember{
    if (chatRoomMember.chatRoomJid == nil) return;
    ChatRoom *room = [self returnChatRoom:chatRoomMember.chatRoomJid];
    [room updateChatRoomMember:chatRoomMember];
}

//创建一个房间
- (void)creatChatRoom:(NSString *)roomJid withPassword:(NSString *)password{
   // XMPPRoomMemoryStorage *roomStorage = [[XMPPRoomMemoryStorage alloc]init];
    XMPPJID *roomJID = [XMPPJID jidWithString:roomJid];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc]initWithRoomStorage:[XmppManager sharedxmppManager].roomCoreData jid:roomJID];
    [xmppRoom activate:[XmppManager sharedxmppManager].xmppStream];
    [xmppRoom joinRoomUsingNickname:[XmppManager sharedxmppManager].userName history:nil password:password];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];

}

//获得某个房间内的某个成员
-(ChatRoomMember*)returnMemberWith:(NSString*)jid
                        inChatRoom:(NSString*)chatRoomJid{
    ChatRoom *room = _chatRoomDict[chatRoomJid];
    if (!room) {
        room = [[ChatRoom alloc]initWithChatRoomJid:chatRoomJid];
        _chatRoomDict[chatRoomJid] = room;
    }
    ChatRoomMember *member = room.memberListDict[jid];
    if (!member) {
        member = [[ChatRoomMember alloc]init];
        member.chatRoomJid = chatRoomJid;
        member.chatRoomMemberJid = jid;
    }
    return member;
}

//邀请一个成员进入房间
-(void)inviteMember:(NSString*)memberJid
      toChatRoomJid:(NSString*)chatRoomJid
             reason:(NSString*)reason
       withPassword:(NSString*)password{
    /*
    <message id="chatroom-1" to="room5@conference.127.0.0.1"><x xmlns="http://jabber.org/protocol/muc#user"><invite to="zhangsan@127.0.0.1"><reason></reason></invite><password></password></x></message>
     */
    
    if ([memberJid rangeOfString:@"@"].location == NSNotFound) {
        memberJid = [NSString stringWithFormat:@"%@@%@",memberJid,[UserOperation shareduser].hostUrl];
    }
    XMPPMessage* message=[[XMPPMessage alloc]init];
    [message addAttributeWithName:@"id" stringValue:@"chatroom-1"];
    [message addAttributeWithName:@"to" stringValue:chatRoomJid];
    NSXMLElement* element_x=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
    [message addChild:element_x];
    NSXMLElement* element_invite=[NSXMLElement elementWithName:@"invite"];
    [element_invite addAttributeWithName:@"to" stringValue:memberJid];
    [element_x addChild:element_invite];
    if (reason) {
        NSXMLElement* element_reason=[NSXMLElement elementWithName:@"reason"];
        element_reason.stringValue=reason;
        [element_invite addChild:element_reason];
    }
    if (password){
        NSXMLElement* element_password=[NSXMLElement elementWithName:@"password"];
        element_password.stringValue=password;
        [element_x addChild:element_password];
    }
    [XMPPSTREAM sendElement:message];

}

//邀请一个成员进入房间ROOM
- (void)inviteUser:(NSString *)jidStr toRoom:(XMPPRoom *)room withMessage:(NSString *)message{
    if ([jidStr rangeOfString:@"@"].location == NSNotFound) {
        jidStr = [NSString stringWithFormat:@"%@@%@",jidStr,[UserOperation shareduser].hostUrl];
    }
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    [room inviteUser:jid withMessage:message];
}

//配置新房间
-(NSXMLElement *)configNewRoom:(XMPPRoom *)room{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"10"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field"];
    [p addAttributeWithName:@"var" stringValue:@"muc#maxhistoryfetch"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"100"]]; //history
    [x addChild:p];
    
    /*
     p = [NSXMLElement elementWithName:@"field" ];
     [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];//房间名称
     [p addChild:[NSXMLElement elementWithName:@"value" stringValue:self.roomTitle]];
     [x addChild:p];
     
     p = [NSXMLElement elementWithName:@"field" ];
     [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enablelogging"];//允许登录对话
     [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
     [x addChild:p];
     */
    return x;
}




#pragma mark muc delegate
-(void)xmppMUC:(XMPPMUC *)sender didDiscoverRooms:(NSArray *)rooms forServiceNamed:(NSString *)serviceName{
    NSLog(@"didDiscoverRooms");
    
    NSLog(@"rooms = %@",rooms);
    NSLog(@"serviceName = %@",serviceName);  //serviceName = conference.127.0.0.1

    /*
     rooms = (
     "<item jid=\"room2@conference.127.0.0.1\" name=\"room2\"></item>",
     "<item jid=\"room3@conference.127.0.0.1\" name=\"room3\"></item>",
     "<item jid=\"room1@conference.127.0.0.1\" name=\"room1\"></item>"
     )
     */
//    
//    [self.roomList removeAllObjects];
    for (XMPPElement * element in rooms) {
        NSString *chatRoomJid = element.attributesAsDictionary[@"jid"];
        NSString *chatRoomName = element.attributesAsDictionary[@"name"];
        if (chatRoomJid ==nil) return;
        ChatRoom *room = [self returnChatRoom:chatRoomJid];
        room.name = chatRoomName;
    }
    ///如果是房间列表返回，那更新通知
    [[NSNotificationCenter defaultCenter]postNotificationName:ChatRoomRefreshRoomsNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter]postNotificationName:RefreshTalksNotification object:nil];
    
//    if (self.updateDateBlock) {
//        self.updateDateBlock(nil);
//    }
    
}

- (void)xmppMUC:(XMPPMUC *)sender failedToDiscoverRoomsForServiceNamed:(NSString *)serviceName withError:(NSError *)error{
    NSLog(@"failedToDiscoverRoomsForServiceNamed");
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverServices:(NSArray *)services{
    NSLog(@"didDiscoverServices");
    NSLog(@"didDiscoverServices = %@",services);
    
    /* didDiscoverServices = (
     "<item jid=\"proxy.127.0.0.1\" name=\"Socks 5 Bytestreams Proxy\"></item>",
     "<item jid=\"conference.127.0.0.1\" name=\"room1\"></item>",
     "<item jid=\"pubsub.127.0.0.1\" name=\"Publish-Subscribe service\"></item>"
     )
     
     */
}

- (void)xmppMUCFailedToDiscoverServices:(XMPPMUC *)sender withError:(NSError *)error{
    NSLog(@"xmppMUCFailedToDiscoverServices");
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message{
    NSLog(@"didReceiveInvitation");
    NSXMLElement * xElement = [message elementForName:@"x"];
    [self joinInChatRoom:[[xElement attributeForName:@"jid"] stringValue] withPassword:nil];
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitationDecline:(XMPPMessage *)message{
    NSLog(@"didReceiveInvitationDecline");
}

#pragma mark xmppRoom delegate

//创建聊天室成功
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidCreate");
}

// 获得聊天室信息
- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidJoin");
    [sender fetchBanList];
    [sender fetchMembersList];
    [sender fetchModeratorsList];
    [sender configureRoomUsingOptions:[self configNewRoom:sender]];
    [sender fetchConfigurationForm];
    
    if (self.inviteFriendsBlock) { 
        self.inviteFriendsBlock(sender);
    }
}

-(void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(DDXMLElement *)configForm{

  //  [self configNewRoom:sender];
}

-(void)xmppRoomDidNotEnter:(XMPPRoom *)sender error:(NSError *)error{

}

//新人加入群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
{
    NSLog(@"occupantDidJoin");
}
//有人退出群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
{
    NSLog(@"occupantDidLeave");
}
//有人在群里发言
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    NSLog(@"didReceiveMessage");
    //occupantJID : room4@conference.127.0.0.1/wushangkun
    /*
    <message xmlns="jabber:client" type="groupchat" to="wushangkun@127.0.0.1/4dxo3oi1xx" from="room4@conference.127.0.0.1/wushangkun"><body>12234</body></message>
     */
}

//离开聊天室
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidLeave");
}

//- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
//{
//    //    DLog(@"configForm:%@",configForm);
//    NSLog(@"didFetchConfigurationForm");
//}
// 收到禁止名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"didFetchBanList");
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"didNotFetchBanList");
}
// 收到好友名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"didFetchMembersList");
    for (NSString * str in items) {
        NSLog(@"items:%@",str);
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    NSLog(@"didNotFetchMembersList");
}

// 收到主持人名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"didFetchModeratorsList");
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    NSLog(@"didNotFetchModeratorsList");
}

- (void)handleDidLeaveRoom:(XMPPRoom *)room
{
    NSLog(@"handleDidLeaveRoom");
}

#pragma mark XMPPRoomStorage Protocol


- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room
{
    NSLog(@"handlePresence");
}

- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    NSLog(@"handleIncomingMessage");
}

- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room
{
    NSLog(@"handleOutgoingMessage");
}

- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}



#pragma mark - XMPPStreamDelegate

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    

}

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    if ([presence isChatRoomPresence]) {
        /*进入房间时获取的其他成员列表
         <presence xmlns="jabber:client" id="GixiF-41" to="adow@222.191.249.155/drrr" from="test@conference.222.191.249.155/bdow">
         <x xmlns="http://jabber.org/protocol/muc#user">
         <item jid="bdow@222.191.249.155/Spark 2.6.3" affiliation="member" role="participant"/>
         </x>
         </presence>
         */
        /*退出房间时收到状态
         <presence xmlns="jabber:client" from="test@conference.222.191.249.155/adow" to="adow@222.191.249.155/drrr" type="unavailable">
         <x xmlns="http://jabber.org/protocol/muc#user">
         <item jid="adow@222.191.249.155/drrr" affiliation="owner" role="none"/></x>
         </presence>
         
         */
        ChatRoomMember *member = [[ChatRoomMember alloc]initWithPresence:presence];
        [self updateGroupRoomMember:member];
    }

}

-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
   /*
    <iq
     xmlns="jabber:client" type="result" id="disco-3" from="127.0.0.1" to="wushangkun@127.0.0.1/adf3bqj7z6">
     <query
       xmlns="http:jabber.org/protocol/disco#items">
       <item jid="proxy.127.0.0.1" name="Socks 5 Bytestreams Proxy"></item>
       <item jid="conference.127.0.0.1" name="room1"></item>
       <item jid="pubsub.127.0.0.1" name="Publish-Subscribe service"></item>
     </query>
    </iq>
    */
    if ([iq isChatRoomItems]) { //房间条目
        //是否是服务器返回的地址
        BOOL isService_result = NO;
        NSXMLElement *element = iq.childElement;
        for (NSXMLElement *element_item in element.children) {
            NSString *chatRoomJid = element_item.attributesAsDictionary[@"jid"];
//            NSString *chatRoomName = element_item.attributesAsDictionary[@"name"];
            ///chatRoomJid里面没有@就说明他只是一个service地址
            if ([chatRoomJid rangeOfString:@"@"].location == NSNotFound) {
                [_chatRoomServices addObject:chatRoomJid];
                isService_result =YES;
            } else {
//                ChatRoom *room = [self returnChatRoom:chatRoomJid];
//                room.name = chatRoomName;
//                isService_result = NO;     //new add
            }
        }
         //如果只是服务地址，那去获取每个服务下的房间列表
        if (isService_result) {
                for (NSString *serviceJid in _chatRoomServices) {
                [self queryChatRoomItems:serviceJid];
            }
        } else{
            ///如果是房间列表返回，那更新通知
            //[[NSNotificationCenter defaultCenter]postNotificationName:ChatRoomRefreshRoomsNotification object:nil];
        }
    }
    
    else if  ([iq isChatRoomInfo]) {  ///房间信息查询
        //
        NSString *chatRoomJid = [[iq from] bare];
        ChatRoom *room = [self returnChatRoom:chatRoomJid];
        ChatRoomInfo *roomInfo = [[ChatRoomInfo alloc]initWithIq:iq];
        room.chatRoomInfo = roomInfo;
        NSLog(@"roomInfo.name = %@",roomInfo.name);
        [[NSNotificationCenter defaultCenter]postNotificationName:ChatRoomRefreshRoomsNotification object:room];
    }
//
    return YES;
}

@end




// ************************************* 聊天室的一个成员 *************************************/
@implementation ChatRoomMember

-(id)initWithPresence:(XMPPPresence *)presence{
    self = [super init];
    if (self) {
        //
        if (presence.childCount > 0) {
            /*进入房间时获取的其他成员列表
             <presence xmlns="jabber:client" id="GixiF-41" to="adow@222.191.249.155/drrr" from="test@conference.222.191.249.155/bdow">
             <x xmlns="http://jabber.org/protocol/muc#user">
             <item jid="bdow@222.191.249.155/Spark 2.6.3" affiliation="member" role="participant"/>
             </x>
             </presence>
             */
            /*退出房间时收到状态
             <presence xmlns="jabber:client" from="test@conference.222.191.249.155/adow" to="adow@222.191.249.155/drrr" type="unavailable">
             <x xmlns="http://jabber.org/protocol/muc#user">
             <item jid="adow@222.191.249.155/drrr" affiliation="owner" role="none"/></x>
             </presence>
             
             */

            for (NSXMLElement* element in presence.children) {
                if ([element.name isEqualToString:@"x"] && [element.xmlns isEqualToString:@"http://jabber.org/protocol/muc#user"]){
                    XMPPJID* jidFrom=[presence from];
                    NSString* chatRoomJid=[jidFrom bare];
                    NSString* chatRoomMemberName=[jidFrom resource];
                    NSXMLElement* element_item=element.children[0];
                    NSString* chatRoomMemberJid=[[XMPPJID jidWithString:element_item.attributesAsDictionary[@"jid"]] bare];
                    NSString* affiliation=element_item.attributesAsDictionary[@"affiliation"];
                    NSString* role=element_item.attributesAsDictionary[@"role"];
                    NSString* nick=element_item.attributesAsDictionary[@"nick"];
                    NSString* status=[presence status];
                    NSString* show=[presence show];
                    self.chatRoomJid=chatRoomJid;
                    self.chatRoomMembername=chatRoomMemberName;
                    self.chatRoomMemberJid=chatRoomMemberJid;
                    self.affiliation=affiliation;
                    self.role=role;
                    self.status=status;
                    self.show=show;
                    self.nick=nick;
                    break;
                }
            }

        }
    }
    
    return self;
}

@end


// ************************************* 聊天室房间信息的各个字段 *************************************/
@implementation ChatRoomInfoField

-(id)initWithVar:(NSString *)var label:(NSString *)label value:(NSString *)value
{
    self=[super init];
    if (self){
        self.var=var;
        self.label=label;
        self.value=value;
    }
    return self;
}

@end

// ************************************* 聊天室房间信息 *************************************/
@implementation ChatRoomInfo

-(NSArray *)features{
    return _features;
}
-(NSDictionary *)fields{
    return _fields;
}

//检查属性
-(BOOL)checkFeature:(NSString*)featureStr{
    for (NSString* feature in _features) {
        if ([feature isEqualToString:featureStr]){
            return YES;
        }
    }
    return NO;
}
-(BOOL)public{
    return [self checkFeature:@"muc_public"];
}
-(BOOL)needPassword{
    return [self checkFeature:@"muc_passwordprotected"];
}
-(BOOL)membersOnly{
    return [self checkFeature:@"muc_membersonly"];
}
-(NSString *)roomDescription{
    return ((ChatRoomInfoField *)_fields[@"muc#roominfo_description"]).value;
}
-(NSString *)subject{
    return ((ChatRoomInfoField *)_fields[@"muc#roominfo_subject"]).value;
}
-(int)occupants{
    return [((ChatRoomInfoField*)_fields[@"muc#roominfo_occupants"]).value intValue];
}
-(NSString*)creationdate{
    return ((ChatRoomInfoField*)_fields[@"x-muc#roominfo_creationdate"]).value;
}

-(id)init
{
    self=[super init];
    if (self){
        _features=[[NSMutableArray alloc]init];
        _fields=[[NSMutableDictionary alloc]init];
    }
    return self;
}
-(id)initWithIq:(XMPPIQ *)iq{
    self=[super init];
    if (self){
        _features=[[NSMutableArray alloc]init];
        _fields=[[NSMutableDictionary alloc]init];
        NSXMLElement* element_query=iq.childElement;
        if ([element_query.xmlns isEqualToString:@"http://jabber.org/protocol/disco#info"]){
            for (NSXMLElement* element in element_query.children) {
                if ([element.name isEqualToString:@"identity"]){
                    self.category=element.attributesAsDictionary[@"category"];
                    self.name=element.attributesAsDictionary[@"name"];
                    self.type=element.attributesAsDictionary[@"type"];
                }
                else if ([element.name isEqualToString:@"feature"]){
                    NSString* value=element.attributesAsDictionary[@"var"];
                    [_features addObject:value]; //添加属性
                }
                else if ([element.name isEqualToString:@"x"]){
                    for (NSXMLElement* element_field in element.children) {
                        NSString* var=element_field.attributesAsDictionary[@"var"];
                        NSString* label=element_field.attributesAsDictionary[@"label"];
                        NSXMLElement* element_value=element_field.children[0];
                        NSString* value=element_value.stringValue;
                        ChatRoomInfoField* field=[[ChatRoomInfoField alloc]initWithVar:var label:label value:value] ;
                        _fields[var]=field;
                    }
                }
            }
        }
    }
    return self;
}
@end


// ************************************* 聊天室房间 *************************************/
@implementation ChatRoom

-(NSDictionary *)memberListDict{
    return _memberListDict;
}

-(id)initWithChatRoomJid:(NSString *)chatRoomJid{
    self=[super init];
    if (self){
//        XMPPJID *jid = [XMPPJID jidWithString:chatRoomJid];
//        XMPPRoom *room = [[XMPPRoom alloc]initWithRoomStorage:[XmppManager sharedxmppManager].roomCoreData jid:jid];
//        self.xmpproom = room;
        self.chatRoomJid=chatRoomJid;
        _memberListDict=[[NSMutableDictionary alloc]init];
    }
    return self;
}

///更新房间成员信息
-(void)updateChatRoomMember:(ChatRoomMember*)chatRoomMember{
    if (![self.chatRoomJid isEqualToString:chatRoomMember.chatRoomJid]){
        NSLog(@"房间号不匹配");
        return;
    }
    //role none的时候从成员中删除
    if ([chatRoomMember.role isEqualToString:@"none"]){
        [_memberListDict removeObjectForKey:chatRoomMember.chatRoomMemberJid];
    } else {
        ///新的成员
        if (!_memberListDict[chatRoomMember.chatRoomMemberJid]) {
            _memberListDict[chatRoomMember.chatRoomMemberJid] = chatRoomMember;
        }
         ///现有成员修改信息，只是复制数据
        else{
            ChatRoomMember *member = _memberListDict[chatRoomMember.chatRoomMemberJid];
            //改名了
            if (chatRoomMember.nick) { ///nick为新名字
                member.chatRoomMembername = chatRoomMember.nick;
            }
            if (chatRoomMember.affiliation){
                member.affiliation=chatRoomMember.affiliation;
            }
            if (chatRoomMember.role){
                member.role=chatRoomMember.role;
            }
            if (chatRoomMember.show){
                member.show=chatRoomMember.show;
            }
            if (chatRoomMember.status){
                member.status=chatRoomMember.status;
            }
        
        }
    
    }
}

///获取房间内的一个成员
-(ChatRoomMember*)chatRoomMember:(NSString*)chatRoomMemberJid{
    return _memberListDict[chatRoomMemberJid];
}

@end
