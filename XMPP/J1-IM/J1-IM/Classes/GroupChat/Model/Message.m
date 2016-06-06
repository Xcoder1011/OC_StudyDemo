//
//  Message.m
//  J1-IM
//
//  Created by wushangkun on 16/1/29.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "Message.h"
#import "XmppManager.h"
#import "Roster.h"
#import "XMPP+HY.h"

@implementation Message

/*
 对应一条XMPP Message，每一条消息都是一个Message模型
 来自一个联系人的chat 时
 
 <message xmlns="jabber:client" id="GixiF-64" to="adow@222.191.249.155" from="bdow@222.191.249.155/Spark 2.6.3" type="chat">
 <body>abc</body>
 <thread>Ll1CIG</thread>
 <x xmlns="jabber:x:event">
 <offline/>
 <composing/>
 </x>
 <delay xmlns="urn:xmpp:delay" from="222.191.249.155" stamp="2014-04-05T12:19:14.506Z"/>
 <x xmlns="jabber:x:delay" from="222.191.249.155" stamp="20140405T12:19:14"/>
 </message>
 
 来自一个多人聊天房间时
 
 <message xmlns="jabber:client" id="1Xuxl-46" to="adow@222.191.249.155/drrr" type="groupchat" from="test@conference.222.191.249.155/bdow">
 <body>aaa</body>
 <x xmlns="jabber:x:event">
 <offline/>
 <delivered/>
 <displayed/>
 <composing/>
 </x>
 <delay xmlns="urn:xmpp:delay" stamp="2014-04-02T06:27:36.747Z" from="test@conference.222.191.249.155/bdow"/>
 <x xmlns="jabber:x:delay" stamp="20140402T06:27:36" from="test@conference.222.191.249.155/bdow"/>
 </message>
 
 也有可能来自一个房间的邀请
 
 <message to="bdow@222.191.249.155" from="test@conference.222.191.249.155">
 <x xmlns="http://jabber.org/protocol/muc#user">
 <invite from="adow@222.191.249.155">
 <reason>test</reason>
 </invite>
 <password>123456</password>
 </x>
 <x xmlns="jabber:x:conference" jid="test@conference.222.191.249.155"/>
 </message>
 
 
 //我发的消息: message7 = <message xmlns="jabber:client" type="groupchat" to="wushangkun@127.0.0.1/1zidwpkhj4" from="room4@conference.127.0.0.1/wushangkun"><body>Xiexie</body><delay xmlns="urn:xmpp:delay" stamp="2016-02-05T05:50:30.065Z" from="wushangkun@127.0.0.1/81fcoo6pra"></delay></message>
 
 //张三的消息: message8 = <message xmlns="jabber:client" id="XDCDu-379" to="wushangkun@127.0.0.1/1zidwpkhj4" type="groupchat" from="room4@conference.127.0.0.1/zhangsan"><body>你不能说中文吗？</body><x xmlns="jabber:x:event"><offline></offline><delivered></delivered><displayed></displayed><composing></composing></x><delay xmlns="urn:xmpp:delay" stamp="2016-02-05T05:50:59.216Z" from="zhangsan@127.0.0.1/Spark"></delay></message>
 
 // messageContent7 = <0x798e6d10 Message toJid=wushangkun@127.0.0.1, toName=wushangkun, fromJid=room4@conference.127.0.0.1, fromName=wushangkun, body=Xiexie, time=(null),type=groupchat,delayTime=2016-02-05 05:50:30 +0000,thread=(null)>
 
 //messageContent8 = <0x7967a720 Message toJid=wushangkun@127.0.0.1, toName=wushangkun, fromJid=room4@conference.127.0.0.1, fromName=zhangsan, body=你不能说中文吗？, time=(null),type=groupchat,delayTime=2016-02-05 05:50:59 +0000,thread=(null)>
 
 */
-(instancetype)initWithXMPPMessage:(XMPPMessage*)message{
    self = [super init];
    if (self) {
        
        self.type = message.type;  //type="groupchat"
        self.fromJid = [message.from bare]; //fromJid=room4@conference.127.0.0.1
        if ([self.type isEqualToString:@"chat"]) {
            self.fromName = [message.from user];
        }
        if ([self.type isEqualToString:@"groupchat"]){
            self.fromName=[message.from resource];  //fromName=zhangsan ,fromName=wushangkun
        }
        self.toJid = [message.to bare];  //toJid=wushangkun@127.0.0.1
        self.toName = [message.to user];  //toName=wushangkun
        self.body = message.body;
        if ([message.body isKindOfClass:[NSString class]]) {
            self.messageType = MessageType_Text;  //文本类消息
        }
        self.thread = message.thread;  //thread=(null)>
        self.messageid = message.attributesAsDictionary[@"id"];  // id="XDCDu-379"
        for (NSXMLElement *element in message.children) {
            if ([element.name isEqualToString:@"delay"]) {
            NSString* delayStr=element.attributesAsDictionary[@"stamp"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            NSArray *arr=[delayStr componentsSeparatedByString:@"T"];
            NSString *dateStr=[arr objectAtIndex:0];
            NSString *timeStr=[[[arr objectAtIndex:1] componentsSeparatedByString:@"."] objectAtIndex:0];
            self.delayTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@T%@+0000",dateStr,timeStr]];
            break;
        }
      }
        
        //chatroom invite
        for (NSXMLElement *element in message.children) {
            self.chatRoom_invite = YES;
            self.chatRoom_invite_chatRoomJid = self.fromJid;  //fromJid=room4@conference.127.0.0.1
            for (NSXMLElement *element_a in element.children) {
                if ([element_a.name isEqualToString:@"invite"])
                {
                    self.chatRoom_invite_fromMemberJid = element_a.attributesAsDictionary[@"from"];
                    for (NSXMLElement *element_b in element_a.children) {
                        if ([element_b.name isEqualToString:@"reason"]) {
                            self.chatRoom_invite_reason = element_b.attributesAsDictionary[@"reason"];
                        }
                    }
                }
                
                if ([element_a.name isEqualToString:@"password"]) {
                    self.chatRoom_invite_password=element_a.stringValue;
                }
            }
        }
    }
    return self;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<0x%lx %@ toJid=%@, toName=%@, fromJid=%@, fromName=%@, body=%@, time=%@,type=%@,delayTime=%@,thread=%@>",(unsigned long)self,[self class],self.toJid,self.toName,self.fromJid,self.fromName,self.body,self.time,self.type,self.delayTime,self.thread];
}

-(NSString *)talkid{
    return self.fromJid;
}

-(BOOL)isChat{
    return [self.type isEqualToString:@"chat"];
}

-(BOOL)isGroupChat{
    return [self.type isEqualToString:@"groupchat"];
}

-(BOOL)mySender{
    if (self.isChat) {
        return [self.fromJid isEqualToString:[XmppManager sharedxmppManager].jidName];  //fromJid=room4@conference.127.0.0.1
    }
    if (self.isGroupChat) {
        return [self.fromName isEqualToString:[XmppManager sharedxmppManager].userName]; //fromName=zhangsan ,fromName=wushangkun
    }
    return NO;
}

-(NSDate*)showTime{
    return self.delayTime?self.delayTime:self.time;
}
@end



@implementation SessionManager

static SessionManager* _sharedSession;
+(SessionManager *)sharedSessionManager{
    if (!_sharedSession) {
        _sharedSession = [[super allocWithZone:NULL]init];
        [_sharedSession setupMessageDict];
    }
    
    return _sharedSession;
}

-(void)setupMessageDict
{
    _messagesDict = [[NSMutableDictionary alloc]init];
}

//-(NSMutableDictionary *)messagesDict{
//    if (!_messagesDict) {
//         _messagesDict = [[NSMutableDictionary alloc]init];
//    }
//    return _messagesDict;
//}

///与一个人的会话列表
-(NSMutableArray *)talksWithJid:(NSString *)jid{
    return _messagesDict[jid];
}

///收到消息
-(void)receiveMessage:(Message *)message{

    NSMutableArray *talks = _messagesDict[message.talkid];
    NSLog(@"_messagesDict1 = %@",_messagesDict);
    if (!talks) {
        talks  = [[NSMutableArray alloc]init];
    }
    if ([message.delayTime description] != NULL) {
        
    }else{
       [talks addObject:message];
    }
   
    _messagesDict[message.talkid] = talks;
    NSLog(@"_messagesDict2 = %@",_messagesDict);


//    if (!talks) {
//        talks = [NSMutableArray array];
//        _messagesDict[message.talkid] = talks;
//        
//    }
    
   // _messagesDict[message.talkid] = talks;
    [[Roster sharedRoster]increaseUnreadMessageNumForJid:message.talkid];
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshTalksNotification object:message];
}

/**
 *  单聊文本消息
 */
-(Message *)sendMessage:(NSString *)messageText toJid:(NSString *)toJid toName:(NSString *)toName{
    
    //1. 生成Message对象
    Message *message = [[Message alloc]init];
    message.toJid = toJid;
    message.toName= toName;
    message.fromJid = [XmppManager sharedxmppManager].jidName;
    message.fromName = [XmppManager sharedxmppManager].userName;
    message.body = messageText;
    message.type = @"chat";
    message.time = [NSDate date];

    NSString *talkId = toJid;
    NSMutableArray *talks = _messagesDict[talkId];
    if (!talks) {
        talks = [NSMutableArray array];
    }
    [talks addObject:message];
    _messagesDict[talkId] = talks;
    
    //2. 发送xml
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成<body>文档
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message.body];
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:toJid];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:[XmppManager sharedxmppManager].userName];
    //组合
    [mes addChild:body];
     //发送消息
    [[XmppManager sharedxmppManager].xmppStream sendElement:mes];
    
    //3. 更新对话列表的通知
    [[NSNotificationCenter defaultCenter]postNotificationName:RefreshTalksNotification object:message];
    
    return message;
}

/**
 *  群聊消息
 */
-(void)sendMessage:(NSString *)messageText inChatRoom:(NSString *)chatRoomJid{
    
//    //1. 生成Message对象
//    Message *message = [[Message alloc]init];
//    message.toJid = chatRoomJid;
//    message.toName= chatRoomJid;
//    message.fromJid = [XmppManager sharedxmppManager].jidName;
//    message.fromName = [XmppManager sharedxmppManager].userName;
//    message.body = messageText;
//    message.type = @"groupchat";
//    message.time = [NSDate date];
//    
//    NSString *talkId = chatRoomJid;
//    NSMutableArray *talks = _messagesDict[talkId];
//    if (!talks) {
//        talks = [NSMutableArray array];
//        _messagesDict[talkId] = talks;
//
//    }
//    //[talks addObject:message];
    
    //2. 发送xml
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成<body>文档
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:messageText];
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
    
    //3. 更新对话列表的通知
    //[[NSNotificationCenter defaultCenter]postNotificationName:RefreshTalksNotification object:message];
    
}


#pragma mark - XMPPStreamDelegate
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    //static int  index = 1;
    if (![message isChatRoomInvite] && !message.body) {
        NSLog(@"body is empty");
        return;
    }
   // NSLog(@"message%d = %@",index++,message);
    
    //我发的消息: message7 = <message xmlns="jabber:client" type="groupchat" to="wushangkun@127.0.0.1/1zidwpkhj4" from="room4@conference.127.0.0.1/wushangkun"><body>Xiexie</body><delay xmlns="urn:xmpp:delay" stamp="2016-02-05T05:50:30.065Z" from="wushangkun@127.0.0.1/81fcoo6pra"></delay></message>
    
    //张三的消息: message8 = <message xmlns="jabber:client" id="XDCDu-379" to="wushangkun@127.0.0.1/1zidwpkhj4" type="groupchat" from="room4@conference.127.0.0.1/zhangsan"><body>你不能说中文吗？</body><x xmlns="jabber:x:event"><offline></offline><delivered></delivered><displayed></displayed><composing></composing></x><delay xmlns="urn:xmpp:delay" stamp="2016-02-05T05:50:59.216Z" from="zhangsan@127.0.0.1/Spark"></delay></message>
    
    Message* messageContent = [[Message alloc]initWithXMPPMessage:message];
  //  NSLog(@"messageContent = %@",messageContent);
    
    // messageContent7 = <0x798e6d10 Message toJid=wushangkun@127.0.0.1, toName=wushangkun, fromJid=room4@conference.127.0.0.1, fromName=wushangkun, body=Xiexie, time=(null),type=groupchat,delayTime=2016-02-05 05:50:30 +0000,thread=(null)>
    
    //messageContent = <0x7967a720 Message toJid=wushangkun@127.0.0.1, toName=wushangkun, fromJid=room4@conference.127.0.0.1, fromName=zhangsan, body=你不能说中文吗？, time=(null),type=groupchat,delayTime=2016-02-05 05:50:59 +0000,thread=(null)>
    
    // <0x7bf87b00 Message toJid=wushangkun@127.0.0.1, toName=wushangkun, fromJid=room5@conference.127.0.0.1, fromName=wushangkun, body=Qwertyuiop, time=(null),type=groupchat,delayTime=(null),thread=(null)>
    
  
    
    [self receiveMessage:messageContent];

}

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //判断进入房间成功没？
   // NSLog(@"判断进入房间成功没？ presence = %@",presence);
   // 判断进入房间成功没？ presence = <presence xmlns="jabber:client" from="room2@conference.127.0.0.1/zhangsan" to="zhangsan@127.0.0.1/7yeir72g8h" type="error"><x xmlns="http://jabber.org/protocol/muc"></x><error code="407" type="auth"><registration-required xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"></registration-required></error></presence>
    
  //   判断进入房间成功没？ presence = <presence xmlns="jabber:client" from="xiaoma@127.0.0.1/wushangkun&#x7684;iMac" to="wushangkun@127.0.0.1"><priority>0</priority><c xmlns="http://jabber.org/protocol/caps" node="http://www.apple.com/ichat/caps" ver="1000" ext="mvideo maudio avcap avavail ice video audio"></c><x xmlns="http://jabber.org/protocol/tune"></x><x xmlns="vcard-temp:x:update"><photo>9B1FC35A552F0B1118F539DB8705FC4F16AD1FC2</photo></x></presence>
    
    //刚进入房间时 <presence xmlns="jabber:client" from="room5@conference.127.0.0.1/wushangkun" to="wushangkun@127.0.0.1/711nv3ezt3"><x xmlns="http://jabber.org/protocol/muc#user"><item jid="wushangkun@127.0.0.1/711nv3ezt3" affiliation="owner" role="moderator"></item><status code="110"></status><status code="100"></status></x></presence>
    
  //  添加成功后对方同意了，判断进入房间成功没？ presence = <presence xmlns="jabber:client" id="NvT7K-647" to="wushangkun@127.0.0.1/5flf8a6uz9" from="room5@conference.127.0.0.1/zhangsan"><x xmlns="http://jabber.org/protocol/muc#user"><item jid="zhangsan@127.0.0.1/Spark" affiliation="none" role="participant"></item></x></presence>
    
}
-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    // <iq xmlns="jabber:client" type="error" to="zhangsan@127.0.0.1/848fktgyd1"><pref xmlns="urn:xmpp:archive"></pref><error code="503" type="cancel"><service-unavailable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"></service-unavailable></error></iq>
    
    //<iq xmlns="jabber:client" type="result" id="disco-3" from="127.0.0.1" to="zhangsan@127.0.0.1/848fktgyd1"><query xmlns="http://jabber.org/protocol/disco#items"><item jid="proxy.127.0.0.1" name="Socks 5 Bytestreams Proxy"></item><item jid="conference.127.0.0.1" name="room1"></item><item jid="pubsub.127.0.0.1" name="Publish-Subscribe service"></item></query></iq>
    return YES;
}


@end
