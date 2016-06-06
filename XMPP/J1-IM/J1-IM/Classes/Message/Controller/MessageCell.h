//
//  MessageCell.h
//  J1-IM
//
//  Created by liang on 16/2/4.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentTextLabel;
@end
