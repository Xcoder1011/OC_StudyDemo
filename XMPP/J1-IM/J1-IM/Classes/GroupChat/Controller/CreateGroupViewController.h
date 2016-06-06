//
//  CreateGroupViewController.h
//  J1-IM
//
//  Created by wushangkun on 16/2/3.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "HYViewController.h"

@interface CreateGroupViewController : HYViewController

@property (nonatomic ,strong) NSMutableArray *selectArray; //选中的用户

@property (nonatomic ,assign) BOOL isInviteMember; //是否是邀请好友


@end
