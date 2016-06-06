//
//  XmppRoomManager.m
//  J1-IM
//
//  Created by wushangkun on 16/1/25.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "XmppRoomManager.h"
#import "UserOperation.h"
#import "MessageObject.h"

#define RefreshTalksNotification @"DRRRRefreshTalksNotification" ///刷新对话列表的通知


@implementation XmppRoomManager

static XmppRoomManager *_manager;

+(XmppRoomManager *)sharedXmppRoomManager
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _manager = [[XmppRoomManager alloc]init];
        [_manager setup];
    });
    return _manager;

}

-(void)setup{
    self.roomList = [NSMutableArray array];
    muc = [[XMPPMUC alloc]init];
    [muc activate:[XmppManager sharedxmppManager].xmppStream];
    [muc addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


- (void)creatChatRoom:(NSString *)roomJid{
    XMPPRoomMemoryStorage *roomStorage = [[XMPPRoomMemoryStorage alloc]init];
    XMPPJID *roomJID = [XMPPJID jidWithString:roomJid];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc]initWithRoomStorage:roomStorage jid:roomJID];
    [xmppRoom activate:[XmppManager sharedxmppManager].xmppStream];
    [xmppRoom joinRoomUsingNickname:[XmppManager sharedxmppManager].userName history:nil password:nil];
}

- (void)queryRooms{
    [ muc discoverRoomsForServiceNamed:[NSString stringWithFormat:@"conference.%@",ServerName]];
    //[muc discoverServices];
}

- (void)queryRoomsInfo:(NSString *)roomJid{
    XMPPIQ* iq=[XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:[XmppManager sharedxmppManager].jidName];
    [iq addAttributeWithName:@"id" stringValue:@"disco-1"];
    [iq addAttributeWithName:@"to" stringValue:roomJid];
    NSXMLElement* element_query=[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    [iq addChild:element_query];
    [[XmppManager sharedxmppManager].xmppStream sendElement:iq];
}

- (void)inviteUser:(NSString *)jidStr toRoom:(XMPPRoom *)room withMessage:(NSString *)message{
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    [room inviteUser:jid withMessage:message];
}

- (void)joinInChatRoom:(NSString *)roomJid withPassword:(NSString *)password{
    NSString* memberJid = [NSString stringWithFormat:@"%@/%@",roomJid,[UserOperation shareduser].username];
    XMPPPresence* presence=[XMPPPresence presence];
    [presence addAttributeWithName:@"from" stringValue:[XmppManager sharedxmppManager].jidName];
    [presence addAttributeWithName:@"to" stringValue:memberJid];
    NSXMLElement* element_x=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
    [presence addChild:element_x];
    if (password){
        NSXMLElement* elemnt_password=[NSXMLElement elementWithName:@"password"];
        [elemnt_password setStringValue:password];
        [element_x addChild:elemnt_password];
    }
    [[XmppManager sharedxmppManager].xmppStream sendElement:presence];
    /*
     <presence from="wushangkun@127.0.0.1" to="room2@conference.127.0.0.1/wushangkun"><x xmlns="http://jabber.org/protocol/muc"></x></presence>
     */
    
}

- (void)sendMessage:(NSString *)message inChatRoom:(NSString *)chatRoomJid{

    ///发送xml
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成<body>文档
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:chatRoomJid];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:[XmppManager sharedxmppManager].jidName];
    //组合
    [mes addChild:body];
    //发送消息
    [[XmppManager sharedxmppManager].xmppStream sendElement:mes];
}


-(NSXMLElement *)configNewRoom:(XMPPRoom *)room{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *field;
    field = [NSXMLElement elementWithName:@"field" ];
    [field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    //[field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomowners"];//谁创建的房间
    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:field];
    
    field = [NSXMLElement elementWithName:@"field" ];
    [field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"20"]];
    [x addChild:field];
    
    field = [NSXMLElement elementWithName:@"field" ];
    [field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:field];
    
    field = [NSXMLElement elementWithName:@"field" ];
    [field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:field];
    
    field = [NSXMLElement elementWithName:@"field" ];
    [field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [field addChild:field];
    
    field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"muc#maxhistoryfetch"];
    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"100"]]; //history
    [x addChild:field];
    
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

    [self.roomList removeAllObjects];
    for (XMPPElement * element in rooms) {
        NSLog(@"element.jid = %@",element.attributesAsDictionary[@"jid"]);
        [self.roomList addObject:element.attributesAsDictionary[@"jid"]];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:RefreshTalksNotification object:nil];

    if (self.updateDateBlock) {
        self.updateDateBlock(nil);
    }
    
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
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidCreate");
}

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

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    //    DLog(@"configForm:%@",configForm);
    NSLog(@"didFetchConfigurationForm");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"didFetchBanList");
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"didNotFetchBanList");
}

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









#pragma mark 获取所有聊天室
-(void)searchAllXmppRoomBlock:(void(^)(NSMutableArray *))rooms
{
    /*
     <iq type="get" to="conference.1000phone.net" id="disco2"><query xmlns="http://jabber.org/protocol/disco#items"></query></iq>
     */
    
    self.RoomsName = rooms;
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    
    XMPPJID *proxyCandidateJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@.%@",GROUND,ServerName]];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"type" to:proxyCandidateJID elementID:@"disco" child:query];
    
    [[XmppManager sharedxmppManager].xmppStream sendElement:iq];

}

#pragma mark 发送群聊消息
-(void)sendRoomMessage:(NSString*)messageStr roomName:(NSString*)roomName
{
    //生成房间jid
    NSString* roomJid = [NSString stringWithFormat:@"%@@%@.%@",roomName,GROUND,ServerName];
    
    XMPPMessage *aMessage = [XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomJid] elementID:[UserOperation shareduser].jid];
    
    //设置发送的内容
    [aMessage addChild:[DDXMLNode elementWithName:@"body" stringValue:messageStr]];
    //发送
    [XMPPSTREAM sendElement:aMessage];
    
    MessageObject *message = [[MessageObject alloc]init];
    message.messageFrom=[UserOperation shareduser].jid;
    message.messageDate=[NSDate date];
    message.messageTo=roomName;
   // message.messageType=GROUPCHAT;
    message.messageContent=messageStr;
    //保存最近聊天记录
    BOOL isSucceed=[MessageObject save:message];
    if (isSucceed) {
        NSLog(@"最近聊天保存成功");
    }
}

#pragma mark 邀请他人进入聊天室
-(void)inviteUserJoinRoom:(XMPPRoom*)room WithUserName:(NSString*)userName
{
    [room inviteUser:[XMPPJID jidWithUser:userName domain:ServerName resource:ZIYUANMING] withMessage:[NSString stringWithFormat:@"邀请你加入%@的聊天室",userName]];
    
    //回调在通过新人进入聊天室获得
}

#pragma mark 拒绝加入聊天室
-(void)rejectJoinRoom:(NSString*)roomJid
{
    XMPPMessage*message=[[XMPPMessage alloc]init];
    [message addAttributeWithName:@"to" stringValue:roomJid];
    NSXMLElement*element=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
    [message addChild:element];
    [XMPPSTREAM sendElement:message];
}


#pragma mark 创建聊天室
//创建聊天室 b为成功加入聊天室以后
-(XMPPRoom*)xmppRoomCreateRoomName:(NSString *)roomName nickName:(NSString *)nickName MessageBlock:(void(^)(NSDictionary*))a presentBlock:(void(^)(NSDictionary*))b
{
    //记录block指针，以及相应的房间jid，为消息接口准备
    self.GroupMessage=a;
    self.GroupPresent=b;
    //对出席列表字典初始化
     self.presentDic=[NSMutableDictionary dictionaryWithCapacity:0];
    NSString*compoRoomJid=[[roomName componentsSeparatedByString:@"@"]firstObject];
    self.nowRoomJid = compoRoomJid;
    //@"room2@conference.127.0.0.1"
    //指定的房间号 如果没有就创建
    XMPPRoom *room = [[XMPPRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@.%@",roomName,GROUND,ServerName]]dispatchQueue:dispatch_get_main_queue()];
    
    //激活
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room activate:XMPPSTREAM];
    
    [MyDefaults removeObjectForKey:GROUNDROOMCONFIG]; //new add
    
     //使用的昵称 进入房间的函数
    [room joinRoomUsingNickname:nickName history:nil];
    [room configureRoomUsingOptions:nil];
 
    return room;

}

#pragma mark 离开房间
-(void)xmppLeaveRoom:(XMPPRoom*)room
{
    _nowRoomJid = nil;
    [room deactivate];
    
    //退出房间删除该房间的配置信息
    [MyDefaults removeObjectForKey:GROUNDROOMCONFIG];
    [MyDefaults synchronize];
}


#pragma mark 修改房间
//修改房间 注！必须是主持人才有此权限
-(void)configRoom:(XMPPRoom*)room roomConfigForm:(NSXMLElement*)roomConfigForm
{
    NSDictionary*dic=[MyDefaults objectForKey:GROUNDNAME];
    //如果没有设置就不改变
    if (dic==nil) {
        //保存配置信息
        [MyDefaults setObject:[roomConfigForm XMLString] forKey:GROUNDROOMCONFIG];
        [MyDefaults synchronize];
        return;
    }
    NSXMLElement*newConfig=nil;
    if (roomConfigForm) {
        newConfig=[roomConfigForm copy];
    }else{
        NSString*str= [MyDefaults objectForKey:GROUNDROOMCONFIG];
        if (str==nil) {
            return;
        }
        newConfig=[[NSXMLElement alloc]initWithXMLString:str error:nil];
    }
    NSArray*fields=[newConfig elementsForName:@"field"];
    /*
     NSDictionary*dic=@{@"nikeName":nikeName.text,@"desName":[NSString stringWithFormat:@"%@",desName.text],@"isOpen":[NSString stringWithFormat:@"%d",isOpen],@"num":[NSString stringWithFormat:@"%d",num]};
     */
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        //房间名称
        if ([var isEqualToString:@"roomconfig_roomname"]&&[dic objectForKey:@"nikeName"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"nikeName"]]];
        }
        //房间描述
        if ([var isEqualToString:@"muc#roomconfig_roomdesc"]&&[dic objectForKey:@"desName"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"desName"]]];
        }
        //房间永久化
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]&&[dic objectForKey:@"isOpen"]) {
            if ([[dic objectForKey:@"isOpen"]isEqualToString:@"1"]) {
                [field removeChildAtIndex:0];
                [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
            }
            
        }
        //设置人数
        if ([var isEqualToString:@"muc#roomconfig_maxusers"]&&[dic objectForKey:@"num"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"num"]]];
            
        }
        //允许改变主题
        if ([var isEqualToString:@"muc#roomconfig_changesubject"]||[var isEqualToString:@"muc#roomconfig_allowinvites"]) {
            
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    
    [MyDefaults setObject:[newConfig XMLString] forKey:GROUNDROOMCONFIG];
    //删除掉配置信息
    [MyDefaults removeObjectForKey:GROUNDNAME];
    [MyDefaults synchronize];
    
    [room configureRoomUsingOptions:newConfig];
    
}

#pragma mark 查找特定房间
-(void)fetchRoomName:(NSString*)roomName FetchRoomBlock:(void(^)(NSDictionary*))fetchRoomConfig{
    /*查询特定房间
     <iq type="get" to="zc12@127.0.0.1" id="disco"><query xmlns="http://jabber.org/protocol/disco#info"/></iq>
     */
    self.FetchRoom=fetchRoomConfig;
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    //conference 原生的
    XMPPJID* proxyCandidateJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@.%@",roomName,GROUND,ServerName]];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:proxyCandidateJID  elementID:@"disco" child:query];
    [XMPPSTREAM sendElement:iq];
    
}



@end
