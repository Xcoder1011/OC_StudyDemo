//
//  SKDownloadCell.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SKDownloadModel;

/**
 *  点击开始缓存/暂定缓存
 */
typedef void(^StartDownloadAciton)(SKDownloadModel *model);

@interface SKDownloadCell : UITableViewCell
/** 图片 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/** 开始下载 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
/** 文件名 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/** 进度条 */
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/** 当前下载进度 */
@property (weak, nonatomic) IBOutlet UILabel *currentProgress;
/** 实时网速 */
@property (weak, nonatomic) IBOutlet UILabel *networkSpeed;

@property (nonatomic, strong) SKDownloadModel *model;

/** 点击开始缓存/暂定缓存 */
@property (nonatomic, copy) StartDownloadAciton startDownloadAciton;

@end
