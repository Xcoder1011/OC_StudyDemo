//
//  ChatBubbleView.h
//  J1-IM
//
//  Created by wushangkun on 16/1/29.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

#define LEFT_BUBBLE_IMAGE @"chat_recive_nor"
#define RIGHT_BUBBLE_IMAGE @"chat_send_nor"

#define INTERVAL_BUBBLE_HEIGHT 8
#define INTERVAL_BUBBLE_WIDTH 10

typedef enum : NSUInteger {
    BubblePressType_Press,
    BubblePressType_LongPress,
    BubblePressType_Again,
} BubblePressType;

@class ChatBubbleView;
@protocol ChatBubbleViewDelegate <NSObject>

/**
 *  气泡的frame改变
 *
 *  @param bubbleView 当前气泡
 *  @param frame      改变之后的frame
 */
- (void)bubbleViewChangeFrame:(ChatBubbleView *)bubbleView Frame:(CGRect)frame;

@end


@interface ChatBubbleView : UIView
{
    UIImageView * _bubbleImageView;
}

@property (nonatomic, strong) Message * message;
@property (nonatomic, copy) void (^eventResponer) (Message * message,BubblePressType type);
@property (nonatomic, assign) id <ChatBubbleViewDelegate> delegate;


/**
 *  通过model 计算当前显示需要的高度
 *
 *  @param model 需要计算的model
 *
 *  @return 计算高度
 */
+ (CGFloat)heightForMessageModel:(Message *)message;

@end
