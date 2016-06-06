//
//  HYDownloadManager.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/31.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDownloadModel.h"

#ifdef DEBUG
#define DLog(s, ... ) NSLog(@"[%@ in line %d] ==== %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s),##__VA_ARGS__])
#else
#define DLog(s, ... )
#endif


@interface HYDownloadManager : NSObject <NSURLSessionDelegate>

/** 下载文件的baseUrl */
@property (nonatomic, copy) NSString *baseUrl;




/**
 *  -------------  下 载  -------------
 *
 *  推 荐 --> 自动判别是 第一次下载 还是 继续下载,
 *         把 开始下载 和 继续下载 结合在一起
 *
 *  @param url       下载文件的URL
 *  @param cachePath 缓存路径
 *  @param progress  下载进度
 *  @param progress  下载状态
 */
- (void)downloadWithUrl:(NSString *)url
              cachePath:(NSString *)cachePath
               progress:(HYDownloadProgressBlock)progress
                  state:(HYDownloadStateBlock)state;



@end
