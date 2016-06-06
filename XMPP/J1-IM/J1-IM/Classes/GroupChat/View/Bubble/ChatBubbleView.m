//
//  ChatBubbleView.m
//  J1-IM
//
//  Created by wushangkun on 16/1/29.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "ChatBubbleView.h"

@implementation ChatBubbleView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bubbleImageView = [[UIImageView alloc] init];
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bubbleImageView];

        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)tapClick:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self postEventResponerType:BubblePressType_Press];
    }
    
}
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self postEventResponerType:BubblePressType_LongPress];
    }
}

- (void)postEventResponerType:(NSInteger)type
{
    if (self.eventResponer) {
        self.eventResponer (self.message, type);
    }
}

- (void)setMessage:(Message *)message
{
    _message = message;
    
    UIImage * image = [UIImage imageNamed:message.mySender ? RIGHT_BUBBLE_IMAGE : LEFT_BUBBLE_IMAGE];
    
    _bubbleImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2 - 1, image.size.width / 2 - 1, image.size.height / 2 + 1, image.size.width / 2 + 1)];
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_delegate && [_delegate respondsToSelector:@selector(bubbleViewChangeFrame:Frame:)]) {
        [_delegate bubbleViewChangeFrame:self Frame:frame];
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
//    frame.origin.y = 20;
    if (self.message.mySender) {
       // frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width;
        frame.origin.x = DeviceWidth - frame.size.width - 48;
        frame.origin.y = 2;


    } else {
       // frame.origin.x = 0;
        frame.origin.x = 48;
        frame.origin.y = 15;


    }
    
    self.frame = frame;
    
    
}

+ (CGFloat)heightForMessageModel:(Message *)message
{
    return 40;
}


@end
