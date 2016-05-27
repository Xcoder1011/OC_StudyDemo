//
//  SKNetworking.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define DLog(s, ... ) NSLog(@"[%@ in line %d] ==== %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s),##__VA_ARGS__])
#else
#define DLog(s, ... )
#endif

/**
 *  下载进度
 *
 *  @param bytesRead      已下载文件的大小
 *  @param totalBytesRead 文件总大小
 */
typedef void(^SKDownloadProgress)(int64_t bytesRead,
                                  int64_t totalBytesRead);

/**
 *  请求成功
 *
 *  @param response 请求成功返回的数据
 */
typedef void(^SKResponseSuccess)(id response);
/**
 *  请求失败
 *
 *  @param error 请求失败错误信息
 */
typedef void(^SKResponseFailure)(NSError *error);

/**
 *  缓存暂停时的回调
 *
 *  @param error error.code = -999
 */
typedef void(^SKResponsePausing)(NSError *error);

/**
 *  所有接口返回的类型都是基类NSURLSessionTask，若要接收返回值
 *  且处理，请转换成对应的子类类型
 */
typedef NSURLSessionTask SKURLSessionTask;
typedef NSURLSessionDownloadTask SKURLSessionDownloadTask;



@interface SKNetworking : NSObject 

/**
 *  获取网络接口的基础URL
 */
+ (NSString *)baseUrl;

/**
 *  开启或关闭接口打印信息,默认是NO
 *
 *  @param isDebug 开发期，是否开启打印信息
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;

/**
 *  设置网络接口的基础url
 */
+ (void)setBaseUrl:(NSString *)baseUrl;

/**
 *  设置请求超时时间，默认为60秒
 *
 *  @param timeout 超时时间
 */
+(void)setTimeout:(NSTimeInterval)timeout;

/**
 *  设置允许同时最大并发数量，默认为3
 */
+(void)setMaxOperationCount:(NSInteger)maxOperationCount;

/**
 *   配置公共的请求头,只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器确定的固定参数设置即可
 */
+ (void)setCommonHttpHeaders:(NSDictionary *)httpHeaders;

/**
 *  开始下载
 *
 *  @param url       下载文件的URL
 *  @param cachePath 缓存路径
 *  @param progress  下载进度
 *  @param success   下载成功回调
 *  @param failure   下载失败回调
 */
+ (SKURLSessionDownloadTask *)startDownloadWithUrl:(NSString *)url
                                 cachePath:(NSString *)cachePath
                                  progress:(SKDownloadProgress)progress
                                   success:(SKResponseSuccess)success
                                   failure:(SKResponseFailure)failure;

/**
 *  暂定下载
 *
 *  @param url 下载文件的URL
 */
+ (void)pauseDownloadWithUrl:(NSString *)url;


/**
 *  继续下载
 */
+ (SKURLSessionDownloadTask *)resumeDownloadWithUrl:(NSString *)url
                     progress:(SKDownloadProgress)progress
                      success:(SKResponseSuccess)success
                      failure:(SKResponseFailure)failure;

/**
 *  取消下载
 *
 *  @param url 下载文件的URL
 */
+ (void)cancelDownloadWithUrl:(NSString *)url;




/**
 *  更新本地存储的下载任务
 */
+ (void)updateLocalAllTasks;


+ (instancetype)shareInstance;


@end
