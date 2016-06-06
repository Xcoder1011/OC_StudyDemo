//
//  ChatViewController.h
//  J1-IM
//
//  Created by liang on 16/1/28.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "HYViewController.h"
#import "XMPPJID.h"
@interface ChatViewController : HYViewController
// 好友的jid
@property (nonatomic, strong) XMPPJID *friendJid;
@end
