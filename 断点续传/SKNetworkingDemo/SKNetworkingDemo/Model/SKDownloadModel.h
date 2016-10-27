//
//  SKDownloadModel.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SKDownloadStatus) {
    kSKDownloadStatusNotLoaded = 1, // 初始状态（未下载）
    kSKDownloadStatusIsLoading,     // 下载中
    kSKDownloadStatusPausing,       // 暂定状态
    kSKDownloadStatusDone,          // 下载完成
    kSKDownloadStatusError          // 下载失败

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
/** 已经下载大小 */
@property (nonatomic, assign) int64_t bytesRead;
/** 文件总的大小 */
@property (nonatomic, assign) int64_t totalBytesRead;
/** 网速 */
@property (nonatomic, strong) NSString* speed;


@end
