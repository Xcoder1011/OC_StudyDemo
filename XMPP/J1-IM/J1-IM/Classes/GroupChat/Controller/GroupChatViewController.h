//
//  GroupChatViewController.h
//  J1-IM
//
//  Created by wushangkun on 16/1/28.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "HYViewController.h"
#import "Roster.h"
#import "Message.h"
#import "GroupChatManager.h"

@interface GroupChatViewController : HYViewController

@property (nonatomic,retain) RosterMember* member;
@property (nonatomic,retain) ChatRoom* chatRoom;

- (id) initWithUserName:(NSString *)_userName;

@end
