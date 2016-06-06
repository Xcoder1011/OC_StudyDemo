//
//  HYDownloadModel.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/31.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HYDownloadingState) {
    kHYDownloadingStateNotLoaded = 0, // 初始状态（未下载）
    kHYDownloadingStateIsLoading,     // 下载中
    kHYDownloadingStateSuspending,    // 暂定状态
    kHYDownloadingStateComplete,      // 下载完成
    kHYDownloadingStateFaile          // 下载失败
};

/**
 *  下载进度
 *
 *  @param bytesRead      已下载文件的大小
 *  @param totalBytesRead 文件总大小
 */
typedef void(^HYDownloadProgressBlock)(int64_t bytesRead,
                                  int64_t totalBytesRead,
                                  NSString *netSpeed);
/**
 *  下载状态
 */
typedef void(^HYDownloadStateBlock)(HYDownloadingState state);


/**
 *  请求成功
 *
 *  @param response 请求成功返回的数据
 */
typedef void(^HYResponseSuccess)(id response);
/**
 *  请求失败
 *
 *  @param error 请求失败错误信息
 */
typedef void(^HYResponseFailure)(NSError *error , HYDownloadingState downloadStatus);


@interface HYDownloadModel : NSObject <NSCoding>
/** tag */
@property (nonatomic, assign) NSInteger tag;
/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件名 */
@property (nonatomic, copy) NSString *fileName;
/** 下载链接 */
@property (nonatomic, copy) NSString *linkUrl;
/** 缓存路径 */
@property (nonatomic, copy) NSString *destinationPath;
/** 获得服务器这次请求 返回数据的总长度 */
@property (nonatomic, assign) NSInteger totalLength;
/** 文件总的大小 */
@property (nonatomic, copy) NSString *totalSize;
/** 开始下载时间 */
@property (nonatomic, strong) NSDate *startTime;
/** 下载状态 */
@property (nonatomic, copy) HYDownloadStateBlock stateBlock;
/** 下载进度 */
@property (nonatomic, copy) HYDownloadProgressBlock progressBlock;



@end
