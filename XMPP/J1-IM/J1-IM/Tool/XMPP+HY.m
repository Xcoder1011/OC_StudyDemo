//
//  XMPP+HY.m
//  J1-IM
//
//  Created by wushangkun on 16/1/26.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "XMPP+HY.h"
#import "XMPP.h"


@implementation XMPPPresence (HY)

///是否来自聊天室的状态
-(BOOL)isChatRoomPresence{
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"x"] &&
                [element.xmlns isEqualToString:@"http://jabber.org/protocol/muc#user"])
                return YES;
         //    <x xmlns="http://jabber.org/protocol/muc"></x>
        }
    }
    return NO;

}
@end





@implementation XMPPIQ (HY)

//是否是获取联系人的请求
-(BOOL)isRosterQuery{
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"query"] && [element.xmlns isEqualToString:@"jabber:iq:roster"]){
                return YES;
            }
        }
    }
    return NO;
}

//是否是房间列表请求
-(BOOL)isChatRoomItems{
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"query"] &&
                [element.xmlns isEqualToString:@"http://jabber.org/protocol/disco#items"]){
                return YES;
            }
        }
    }
    return NO;
}


//是否是房间信息查询
-(BOOL)isChatRoomInfo{
    /*
    <iq
      xmlns="jabber:client" type="get" id="14-14" from="127.0.0.1" to="wushangkun@127.0.0.1/adf3bqj7z6">
      <ping
        xmlns="urn:xmpp:ping">
      </ping>
    </iq>
     */
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"query"] &&
                [element.xmlns isEqualToString:@"http://jabber.org/protocol/disco#info"]){
                BOOL has_identity=NO; 
                BOOL has_feature=NO;
                for (NSXMLElement* element_item in element.children) {
                    if ([element_item.name isEqualToString:@"identity"]){
                        has_identity=YES;
                    }
                    if ([element_item.name isEqualToString:@"feature"]){
                        has_feature=YES;
                    }
                }
                return has_identity && has_feature;
            }
        }
    }
    return NO;
}
@end



@implementation XMPPMessage (HY)

///是否是来自房间邀请
-(BOOL)isChatRoomInvite{
    if (self.childCount > 0) {
        for (NSXMLElement *element in self.children) {
            if ([element.name isEqualToString:@"x"] &&
                [element.xmlns isEqualToString:@"http://jabber.org/protocol/muc#user"]) {
                for (NSXMLElement *element_a in element.children) {
                    if ([element_a.name isEqualToString:@"invite"]) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

@end
