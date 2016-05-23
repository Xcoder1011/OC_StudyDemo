//
//  SKDownloadCell.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SKDownloadCell.h"
#import "SKDownloadModel.h"


@implementation SKDownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.progressView.progress = 0.0;
}

- (IBAction)tapIconImageView:(UITapGestureRecognizer *)sender {
    
    NSLog(@"点击了图像");
//    self.model
    if (self.startDownloadAciton) {
        self.startDownloadAciton(self.model);
    }
}

-(void)setModel:(SKDownloadModel *)model{
    _model = model;
    self.titleLabel.text = model.name;
}


-(void)updateConstraints {
    [super updateConstraints];
    
    
}


@end
