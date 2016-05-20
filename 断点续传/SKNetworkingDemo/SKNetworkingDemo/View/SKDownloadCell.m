//
//  SKDownloadCell.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SKDownloadCell.h"

@implementation SKDownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = @"功夫熊猫.zip";
    
}

- (IBAction)tapIconImageView:(UITapGestureRecognizer *)sender {
    
    NSLog(@"点击了图像");
}


-(void)updateConstraints {
    [super updateConstraints];
    
    
}


@end
