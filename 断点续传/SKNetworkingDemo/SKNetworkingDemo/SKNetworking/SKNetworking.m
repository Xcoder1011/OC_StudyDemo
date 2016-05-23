//
//  SKNetworking.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SKNetworking.h"
#import <AFNetworking.h>
//#import <AFHTTPSessionManager.h>
//#import <AFNetworkReachabilityManager.h>

static NSString *default_baseUrl = nil;
static NSTimeInterval default_timeout = 60.0f;
static NSInteger default_maxConcurrentOperationCount = 3;
static NSDictionary *default_httpheaders = nil;
static BOOL default_enableInterfaceDebug = NO;
static NSMutableArray *default_requestTasks;

@implementation SKNetworking

+ (NSString *)baseUrl {
   return  default_baseUrl;
}

+ (void)enableInterfaceDebug:(BOOL)isDebug{
    default_enableInterfaceDebug = isDebug;
}

+(void)setBaseUrl:(NSString *)baseUrl {
    default_baseUrl = baseUrl;
}

+ (void)setTimeout:(NSTimeInterval)timeout {
    default_timeout = timeout;
}
+ (void)setMaxOperationCount:(NSInteger)maxOperationCount {
    default_maxConcurrentOperationCount = maxOperationCount;
}

+ (void)setCommonHttpHeaders:(NSDictionary *)httpHeaders {
    default_httpheaders = httpHeaders;
}


+ (SKURLSessionTask *)downloadWithUrl:(NSString *)url
                            cachePath:(NSString *)cachePath
                             progress:(SKDownloadProgress)progress
                              success:(SKResponseSuccess)success
                              failure:(SKResponseFailure)failure{
    
    if (![self checkUrlWithUrl:url]) {
        return nil;
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFHTTPSessionManager *manager = [self _manager];
    
    SKURLSessionTask *session = nil;
    
    session = [manager downloadTaskWithRequest:downloadRequest
                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                          if (progress) {
                                              progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                                          }
                                      }
                                   destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                       return [NSURL URLWithString:cachePath];
                                   }
                             completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                 
                                 [[self allTasks] removeObject:session];
                                 
                                 if (error) { // 错误
                                     [self handleCallbackWithError:error fail:failure];
                                     if (default_enableInterfaceDebug) {
                                         DLog(@"Download fail for url:%@, reason:%@",[self absoluteUrlWithUrl:url],[error description]);
                                     }
                                 }else { // 没有错误
                                     if (success) {
                                         success(filePath.absoluteString);
                                     }
                                     if (default_enableInterfaceDebug) {
                                         DLog(@"Download success for url:%@",[self absoluteUrlWithUrl:url]);
                                     }
                                 }
                             }];
    // 启动任务
    [session resume];

    if (session) {
        [[self allTasks]addObject:session];
    }
    
    return session;
}



#pragma private Method

/**
 *  获取完整的请求链接
 *
 *  @param url 传过来的Url
 *
 *  @return 完整的请求链接
 */
+ (NSString *)absoluteUrlWithUrl:(NSString *)url {
    if (!url || url.length == 0) {
        return @"";
    }
    if (![self baseUrl] || [self baseUrl].length == 0) {
        return url;
    }
    
    NSString *absoluteUrl = @"";
    
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) { // url没有http开头
        
        if ([[self baseUrl]hasSuffix:@"/"])  // baseUrl的末尾字符是"/"
        {
            if([url hasPrefix:@"/"]) { // url的第一个字符是"/"
                NSMutableString *mutaUrl = [NSMutableString stringWithString:url];
                [mutaUrl deleteCharactersInRange:NSMakeRange(0, 1)];
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl],mutaUrl];
            }
            if(![url hasPrefix:@"/"]) {// url的第一个字符没有"/"
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl],url];
            }
        }
        
        if (![[self baseUrl]hasSuffix:@"/"])  //baseUrl的末尾字符没有"/"
        {
            if([url hasPrefix:@"/"]) { // url的第一个字符是"/"
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl],url];
            }
            if(![url hasPrefix:@"/"]) { // url的第一个字符没有"/"
                absoluteUrl = [NSString stringWithFormat:@"%@/%@",[self baseUrl],url];
            }
        }
    }else { // http开头的
        absoluteUrl = url;
    }
    
    return absoluteUrl;
}

/**
 *  处理失败的回调
 */
+ (void)handleCallbackWithError:(NSError *)error fail:(SKResponseFailure)fail {

    if ([error code] == NSURLErrorCancelled) {
        // new add
        if (fail) {
            fail(error);
        }
    }else {
        if (fail) {
            fail(error);
        }
    }
}

/**
 *  所有的请求任务
 */
+(NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (default_requestTasks == nil) {
            default_requestTasks = [[NSMutableArray alloc]init];
        }
    });
    return default_requestTasks;
}

+ (AFHTTPSessionManager *)_manager {

    AFHTTPSessionManager *manager = nil;
    
    if (![self baseUrl]) {
        manager = [AFHTTPSessionManager manager];
    }else {
        manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    }
    // 请求超时时间
    manager.requestSerializer.timeoutInterval = default_timeout;
    // 允许同时最大并发数量
    manager.operationQueue.maxConcurrentOperationCount = default_maxConcurrentOperationCount;
    // 配置请求头
    for (NSString *key in default_httpheaders) {
        if (default_httpheaders[key] != nil) {
            [manager.requestSerializer setValue:default_httpheaders[key] forHTTPHeaderField:key];
        }
    }
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    return manager;
}





// 检测URL是否有效
+ (BOOL)checkUrlWithUrl:(NSString *)url{
    if (![self baseUrl]) {
        // nil
        if (![NSURL URLWithString:url]) {
            DLog(@"url无效，可能是URL中有中文,请尝试Encode URL");
            return NO;
        }
    }else {
        if (![NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[self baseUrl],url]]) {
            DLog(@"url无效，可能是URL中有中文,请尝试Encode URL");
            return NO;
        }
    }
    return YES;
}



@end
