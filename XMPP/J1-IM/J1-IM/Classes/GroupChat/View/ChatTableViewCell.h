//
//  ChatTableViewCell.h
//  J1-IM
//
//  Created by wushangkun on 16/1/28.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "Roster.h"
#import "ChatTextBubbleView.h"

typedef enum : NSUInteger {
    MenuItemType_Copy,
    MenuItemType_Delete,
    MenuItemType_Again,
} MenuItemType;

@interface ChatTableViewCell : UITableViewCell <ChatBubbleViewDelegate>
{
    Message * _message;
}

@property (nonatomic, strong) UILabel  *nameLabel; //姓名
@property (nonatomic, strong) UIImageView *iconImage; //头像

@property (nonatomic, strong) Message  *message;
@property (nonatomic, readonly) ChatBubbleView * bubbleView;
@property (nonatomic, copy) void (^menuItemClick) (ChatTableViewCell *,MenuItemType);

/**
 *  通过model 初始化不同的 cell
 *
 *  @param model
 *
 *  @return cell
 */
- (id)initWithMessageModel:(Message *)message;

/**
 *  通过 model 计算高度
 *
 *  @param model
 *
 *  @return
 */
+ (CGFloat)heightForMessageModel:(Message *)message;
/**
 *  根据model 的不同类型返回不同的 Identifier
 *
 *  @param model
 *
 *  @return identifier
 */
+ (NSString *)cellIdentifierForMessageModel:(Message *)message;

@end
