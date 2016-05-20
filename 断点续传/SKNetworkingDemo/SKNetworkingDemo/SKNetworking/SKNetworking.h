//
//  SKNetworking.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 *  所有接口返回的类型都是基类NSURLSessionTask，若要接收返回值
 *  且处理，请转换成对应的子类类型
 */
typedef NSURLSessionTask SKURLSessionTask;


@interface SKNetworking : NSObject

/**
 *  网络接口的基础URL
 */
+ (NSString *)baseUrl;

/**
 *  下载文件
 *
 *  @param url       下载URL
 *  @param cachePath 缓存路径
 *  @param progress  下载进度
 *  @param success   下载成功回调
 *  @param failure   下载失败回调
 */
+ (SKURLSessionTask *)downloadWithUrl:(NSString *)url
                            cachePath:(NSString *)cachePath
                             progress:(SKDownloadProgress)progress
                              success:(SKResponseSuccess)success
                              failure:(SKResponseFailure)failure;

@end
