//
//  SKDownloadModel.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SKDownloadStatus) {
    kSKDownloadStatusNotLoaded = 1, //没被下载
    kSKDownloadStatusIsLoading,  // 正在下载
    kSKDownloadStatusPausing,  // 停止下载（暂定）状态
    kSKDownloadStatusDone,   // 下载完成
    kSKDownloadStatusError    // 下载出错

};

@interface SKDownloadModel : NSObject
/** title */
@property (nonatomic, strong) NSString *name;
/** 下载链接 */
@property (nonatomic, strong) NSString *linkUrl;
/** 缓存路径 */
@property (nonatomic, strong) NSString *destinationPath;
/** 下载状态 */
@property (nonatomic, assign) SKDownloadStatus status;
/** tag */
@property (nonatomic, assign) NSInteger tag;



@end
