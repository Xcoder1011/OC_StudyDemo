//
//  Roster.m
//  J1-IM
//
//  Created by wushangkun on 16/1/29.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "Roster.h"
#import "XMPP+HY.h"
#import "XmppManager.h"


@implementation RosterMember

-(id)initWithPresence:(XMPPPresence*)presence{
    self = [super init] ;
    if (self) {
        if (![presence isChatRoomPresence]) {
            XMPPJID *jidFrom = [presence from];
            self.jid = [jidFrom bare];
            self.name = [jidFrom user];
            self.status = [presence status];
            self.show = [presence show];
            self.availableStr = [presence type];
        }
    }
    return self;
}


-(id)initWithRosterElement:(NSXMLElement*)element{
    self = [super init] ;
    if (self) {
        NSString *jid = element.attributesAsDictionary[@"jid"];
        NSString* name=element.attributesAsDictionary[@"name"];
        NSString* subscription=element.attributesAsDictionary[@"subscription"];
        NSString* group=nil;
        if (element.children.count > 0) {
            NSXMLElement *element_group = element.children[0];
            if ([element_group.name isEqualToString:@"group"]) {
                group = element_group.stringValue;
            }
        }
        self.jid = jid;
        self.name = name;
        self.subscription = subscription;
        self.group = group;
    }
    return self;
}


@end




// ************************************ 联系人列表 ************************************ /


@implementation Roster
static Roster *_sharedRoster ;

+(Roster *)sharedRoster{
    if (!_sharedRoster) {
        _sharedRoster = [[super allocWithZone:NULL]init];
    }
    return _sharedRoster;
}


-(NSMutableDictionary *)memberListDict{
    if (!_memberListDict) {
        _memberListDict=[[NSMutableDictionary alloc]init];
    }
    return _memberListDict;
}

///更新一个联系人信息
-(RosterMember*)updateMemberInfo:(RosterMember*)member{
    if (!self.memberListDict[member.jid]) {
        self.memberListDict[member.jid] = member;
        [[NSNotificationCenter defaultCenter]postNotificationName:RosterUpdateNotification object:member];
        return member;
    }
    else{
        RosterMember *updateMember = self.memberListDict[member.jid];
        if (member.name){
            updateMember.name=member.name;
        }
        if (member.status){
            updateMember.status=member.status;
        }
        if (member.group){
            updateMember.group=member.group;
        }
        if (member.subscription){
            updateMember.subscription=member.subscription;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:RosterUpdateNotification object:member];
        return updateMember;
    }
}

///获取一个联系人信息
-(RosterMember*)memberByJid:(NSString *)jid{
    return self.memberListDict[jid];
}

///获取一个联系人信息
-(RosterMember*)memberAtIndex:(int)index{
    NSString *jid = self.memberListDict.allKeys[index];
    return [self memberByJid:jid];
}

///当前登录的用户
-(RosterMember*)currentLoginMember{
    return [self memberByJid:[XmppManager sharedxmppManager].jidName];
}

///获取联系人的列表
-(void)queryRosterList{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:self.currentLoginMember.jid];
    [iq addAttributeWithName:@"id" stringValue:@"roster-1"];
    NSXMLElement *element_query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [iq addChild:element_query];
    [[XmppManager sharedxmppManager].xmppStream sendElement:iq];
}

///增加未读消息数量
-(RosterMember*)increaseUnreadMessageNumForJid:(NSString*)jid
{
    RosterMember *member = [self memberByJid:jid];
    member.unread_total ++;
    [[NSNotificationCenter defaultCenter]postNotificationName:RosterUpdateNotification object:member];
    return member;
}


///清空未读消息数量
-(RosterMember*)clearUnreadMessageNumForJid:(NSString*)jid{
    RosterMember *member = [self memberByJid:jid];
    member.unread_total = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:RosterUpdateNotification object:member];
    return member;
}

#pragma mark - XMPPStreamDelegate
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
}
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    ///只处理非chatRoom 状态
    if ([presence isChatRoomPresence]){
        return;
    }
    RosterMember* member=[[RosterMember alloc]initWithPresence:presence];
    [self updateMemberInfo:member];
    
}
-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
  
   /* <iq xmlns="jabber:client" type="result" id="41135446-87FA-4F90-BD34-BD32F2C9047C" to="wushangkun@127.0.0.1/8lapedbhik"><query xmlns="jabber:iq:roster"><item jid="zhangsan@127.0.0.1" name="zhangsan" ask="subscribe" subscription="from"><group>Friends</group></item><item jid="xiaoma@127.0.0.1" name="??" ask="subscribe" subscription="from"></item><item jid="lining@127.0.0.1" name="lining" subscription="both"><group>Friends</group></item><item jid="xiongshaohua@127.0.0.1" name="??" ask="subscribe" subscription="none"></item><item jid="lisi@127.0.0.1" ask="subscribe" subscription="none"></item><item jid="xiaoshaohua@127.0.0.1" ask="subscribe" subscription="none"></item><item jid="xiongshaohua@wushangkundeimac.local" subscription="both"></item></query></iq>
    */

    if ([iq isRosterQuery]){
        NSXMLElement* element_query=iq.childElement;
        if ([element_query.name isEqualToString:@"query"] && [element_query.xmlns isEqualToString:@"jabber:iq:roster"]){
            for (NSXMLElement* element_item in element_query.children) {
                
                RosterMember* member=[[RosterMember alloc]initWithRosterElement:element_item];
                [self updateMemberInfo:member];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:RosterUpdateNotification object:nil];
    }
    return  YES;
}



@end
