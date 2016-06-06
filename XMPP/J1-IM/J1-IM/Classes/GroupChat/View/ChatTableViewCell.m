//
//  ChatTableViewCell.m
//  J1-IM
//
//  Created by wushangkun on 16/1/28.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell
@synthesize bubbleView;

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setMessage:(id)message
{
    _message = message;
    
    if ([message isKindOfClass:[NSString class]]) {
       // _timeView.time = message;
    } else {
        bubbleView.delegate = self;
        bubbleView.message = message;
        [bubbleView sizeToFit];
    }
}

/**
 *  根据 model 返回不同类型的 bubbleView
 *
 *  @param model
 *
 *  @return bubbleview
 */
- (UIView *)prepareBubbleViewForModel:(Message *)message
{
    UIView * bubble = nil;
    
//    // 时间类型
//    if ([message isKindOfClass:[NSString class]]) {
//        bubble = [[ChatTableCellTimeView alloc] init];
//        return bubble;
//    }
    
    switch (message.messageType) {
        case MessageType_Text:
        {
            bubble = [[ChatTextBubbleView alloc] init];
        }
            break;
        case MessageType_Image:
        {
           // bubble = [[ChatImageBubbleView alloc] init];
        }
            break;
        case MessageType_Location:
        {
           // bubble = [[ChatLocationBubbleView alloc] init];
        }
            break;
        case MessageType_Audio:
        {
            //bubble = [[ChatAudioBubbleView alloc] init];
        }
            break;
        default:
            break;
    }
    
    return bubble;

}

// MARK: - ChatBubbleView Delegate
- (void)bubbleViewChangeFrame:(ChatBubbleView *)bubbleView Frame:(CGRect)frame
{

//    CGRect stateFrame = CGRectMake(0, 0, 30, 30);
//    
//    Message * mess = self.message;
//    
//    if (mess.mySender) {
//        stateFrame.origin.x = frame.origin.x - 20;
//    } else {
//        stateFrame.origin.x = frame.origin.x + frame.size.width;
//    }
//    stateFrame.origin.y = frame.size.height - 25; // (CGRect) stateFrame = (origin = (x = 166.11377, y = 0), size = (width = 30, height = 30))
    
    
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}



/**
 *  通过model 初始化不同的 cell
 *
 *  @param model
 *
 *  @return cell
 */
- (id)initWithMessageModel:(Message *)message{
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ChatTableViewCell cellIdentifierForMessageModel:message]];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 时间类型
        if ([message isKindOfClass:[NSString class]]) {
            //_timeView = (ChatTableCellTimeView *)[self prepareBubbleViewForModel:message];
            //[self.contentView addSubview:_timeView];
        } else {
            bubbleView = (ChatBubbleView *)[self prepareBubbleViewForModel:message];
            [self.contentView addSubview:bubbleView];
        }
        
            if (message.mySender) { //是我发送的
            UILabel *nameLabel = [UILabel new];
            self.nameLabel = nameLabel;
            self.iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(DeviceWidth-45, 2, 40, 40)];
                self.iconImage.image = [UIImage imageNamed:@"Snip20160217_2.png"];
            self.iconImage.layer.cornerRadius = 20;
            self.iconImage.layer.masksToBounds = YES;

        }else{
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(50+10, 2, 100, 15)];
            nameLabel.text = message.fromName;
            nameLabel.font = [UIFont systemFontOfSize:12];
            nameLabel.textColor = [UIColor blackColor];
            self.nameLabel = nameLabel;
            self.iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 2, 40, 40)];
            self.iconImage.image = [UIImage imageNamed:@"Snip20160217_1.png"];
            self.iconImage.layer.cornerRadius = 20;
            self.iconImage.layer.masksToBounds = YES;
        }
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.iconImage];

        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;

}





/**
 *  根据model 的不同类型返回不同的 Identifier
 *
 *  @param model
 *
 *  @return identifier
 */
+ (NSString *)cellIdentifierForMessageModel:(Message *)message{
    
    NSString *identifier = @"MessageCell";

    if (message.mySender) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    
    switch (message.messageType) {
        case MessageType_Text:
        {
            identifier = [identifier stringByAppendingString:@"Text"];
        }
            break;
        case MessageType_Image:
        {
            identifier = [identifier stringByAppendingString:@"Image"];
        }
            break;
        case MessageType_Location:
        {
            identifier = [identifier stringByAppendingString:@"Location"];
        }
            break;
        case MessageType_Audio:
        {
            identifier = [identifier stringByAppendingString:@"Audio"];
        }
            break;
        default:
            break;
    }
    
    return identifier;
    
}


/**
 *  通过 model 计算高度
 *
 *  @param model
 *
 *  @return
 */
+ (CGFloat)heightForMessageModel:(Message *)message{
    CGFloat height = 45;
    
//    // 时间类型
//    if ([message isKindOfClass:[NSString class]]) {
//        return height;
//    }
    
    switch (message.messageType) {
        case MessageType_Text:
            height = [ChatTextBubbleView heightForMessageModel:message];
            break;
        case MessageType_Image:
            //height = [ChatImageBubbleView heightForMessageModel:message];
            break;
        case MessageType_Location:
            //height = [ChatLocationBubbleView heightForMessageModel:message];
            break;
        case MessageType_Audio:
           // height = [ChatAudioBubbleView heightForMessageModel:message];
            break;
        default:
            break;
    }
    if (message.mySender) {
        return height+10;
    }
    return height + 30;

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
