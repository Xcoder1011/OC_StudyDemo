//
//  ChatTextBubbleView.m
//  J1-IM
//
//  Created by wushangkun on 16/1/29.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "ChatTextBubbleView.h"

#define MAX_TEXT_WIDTH 200
#define MIN_TEXT_WIDTH 60

#define TEXT_FONT_SIZE 14
@implementation ChatTextBubbleView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.textLabel];
        
    }
    return self;
}


- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor whiteColor];
        
    }
    
    return _textLabel;
}

- (void)setMessage:(Message *)message
{
    [super setMessage:message];
    _textLabel.text = message.body;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    
    frame = CGRectInset(frame, INTERVAL_BUBBLE_WIDTH, INTERVAL_BUBBLE_HEIGHT);
    frame.size.width -= INTERVAL_BUBBLE_WIDTH;

    if (self.message.mySender) {
        frame.origin.x += INTERVAL_BUBBLE_WIDTH - 4;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        if (_textLabel.text.length <= 3) {
            _textLabel.textAlignment = NSTextAlignmentCenter;
            frame.origin.x -= INTERVAL_BUBBLE_WIDTH / 2.0f - 2;
        }
    } else {
        frame.origin.x += INTERVAL_BUBBLE_WIDTH / 2.0f + 4;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        if (_textLabel.text.length <= 3) {
            _textLabel.textAlignment = NSTextAlignmentCenter;
            frame.origin.x = INTERVAL_BUBBLE_WIDTH + INTERVAL_BUBBLE_WIDTH / 2.0f;
        }
    }
    _textLabel.frame = frame;
    
}



- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize maxSize = CGSizeMake(MAX_TEXT_WIDTH + INTERVAL_BUBBLE_WIDTH * 2, CGFLOAT_MAX);
    CGSize calculateSize = CGSizeZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    
    calculateSize = [self.message.body boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:TEXT_FONT_SIZE]} context:nil].size;
#else
    
    calculateSize = [self.message.body sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
#endif
    
    //calculateSize.width = MAX(MIN_TEXT_WIDTH, calculateSize.width + INTERVAL_BUBBLE_WIDTH * 2 + INTERVAL_BUBBLE_WIDTH);
    calculateSize.width = MAX(MIN_TEXT_WIDTH, calculateSize.width + INTERVAL_BUBBLE_WIDTH * 2 );

    calculateSize.width += 15; //保证字数少的情况下是一行
//    calculateSize.height = MAX(35 + INTERVAL_BUBBLE_HEIGHT + 15, calculateSize.height + INTERVAL_BUBBLE_HEIGHT * 2 + 20);
    calculateSize.height = MAX(35 + INTERVAL_BUBBLE_HEIGHT + 15, calculateSize.height + INTERVAL_BUBBLE_HEIGHT * 2 + 20);

    
    return calculateSize ;  //  calculateSize = (width = 133.88623, height = 58)
}


+ (CGFloat)heightForMessageModel:(Message *)message
{
    CGSize maxSize = CGSizeMake(MAX_TEXT_WIDTH + INTERVAL_BUBBLE_WIDTH * 2, CGFLOAT_MAX);
    CGSize calculateSize = CGSizeZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    
    calculateSize = [message.body boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:TEXT_FONT_SIZE]} context:nil].size;
#else
    
    calculateSize = [message.body sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
#endif
    
    calculateSize.height = MAX(35 + INTERVAL_BUBBLE_HEIGHT + 15, calculateSize.height + INTERVAL_BUBBLE_HEIGHT * 2 + 20);
    
    return calculateSize.height ;
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end