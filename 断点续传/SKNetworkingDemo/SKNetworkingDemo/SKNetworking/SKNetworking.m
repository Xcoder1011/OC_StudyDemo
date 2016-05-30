//
//  SKNetworking.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SKNetworking.h"
#import <AFNetworking.h>

static NSString *default_baseUrl = nil;
static NSTimeInterval default_timeout = 60.0f;
static NSInteger default_maxConcurrentOperationCount = 3;
static NSDictionary *default_httpheaders = nil;
static BOOL default_enableInterfaceDebug = NO;
static NSMutableArray *default_requestTasks; //所有的下载任务

@interface SKNetworking ()

@end

@implementation SKNetworking

static SKNetworking *_sknetworking = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _sknetworking = [[SKNetworking alloc]init];
    });
    return _sknetworking;
}

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

static inline NSString *getCachePath() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

#pragma mark -- 开始下载
+ (SKURLSessionDownloadTask *)startDownloadWithUrl:(NSString *)url
                                 cachePath:(NSString *)cachePath
                                  progress:(SKDownloadProgress)progress
                                   success:(SKResponseSuccess)success
                                   failure:(SKResponseFailure)failure{
    
    if (![self checkUrlWithUrl:url]) {
        return nil;
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    
    // AFHTTPSessionManager *manager = [self _manager];
    
    SKURLSessionDownloadTask *sessionTask = nil;
  
    sessionTask = [manager downloadTaskWithRequest:downloadRequest
                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                          if (progress) {
                                              //NSLog(@"download - %f", downloadProgress.fractionCompleted);
                                              progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                                          }
                                      }
                                   destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                                       NSString *path = [getCachePath() stringByAppendingPathComponent:cachePath];
//                                       return [NSURL URLWithString:path];
                                       NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                       NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
                                       return [NSURL fileURLWithPath:path];
                                   }
                             completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                 
                                 if (error) { // 错误
                                     [self handleCallbackWithError:error fail:failure];
                                     
                                     if (default_enableInterfaceDebug) {
                                         DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                     }
                                 }else { // 没有错误
                                     if (success) {
                                         // 删除当前的下载任务
                                         [self _deleteTaskDictWithUrl:url];
                                         
                                         success(filePath.absoluteString);
                                     }
                                     if (default_enableInterfaceDebug) {
                                         DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                     }
                                 }
                             }];
    
    
    
    // 启动任务
    [sessionTask resume];

    if (sessionTask) {
        // 已经下载的局部数据
        NSData *partialData = nil;
        // 包装一个下载任务
        NSMutableDictionary *dicNew = [NSMutableDictionary
                                       dictionaryWithObjectsAndKeys:url,@"url",
                                                              cachePath,@"path",
                                                                sessionTask,@"session",
                                                            partialData,@"partialData", nil];

        // 保存下载任务
        [[self allTasks]addObject:dicNew];
        [self writeToLocalFileWithAllTask:[self allTasks]];
    }
    return sessionTask;
}

#pragma mark -- 暂停下载
+ (void)pauseDownloadWithUrl:(NSString *)url {
    
    if (![self _getSessionTaskWithUrl:url]) {
        return;
    }
    
    NSURLSessionDownloadTask *sessionTask = [self _getSessionTaskWithUrl:url];
    
    [sessionTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        for (NSMutableDictionary *sessionDict in [self allTasks]) {
            if (sessionDict[@"url"] == url) {
                if (resumeData) {
                    [sessionDict setObject:resumeData forKey:@"partialData"];
                }
                [self writeToLocalFileWithAllTask:[self allTasks]];
            }
        }
    }];
}

#pragma mark --  继续下载
+ (SKURLSessionDownloadTask *)resumeDownloadWithUrl:(NSString *)url
                     progress:(SKDownloadProgress)progress
                      success:(SKResponseSuccess)success
                      failure:(SKResponseFailure)failure {
    
    // 1.更新本地数据
    [self updateLocalAllTasks];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    
    SKURLSessionDownloadTask *sessionTask = nil;
    if (![self _getPartialDataWithUrl:url]) {
        return sessionTask;
    }
    
    sessionTask = [manager downloadTaskWithResumeData:[self _getPartialDataWithUrl:url]
                                         progress:^(NSProgress * _Nonnull downloadProgress) {
                                             
                                             if (progress) {
                                                 //NSLog(@"download - %f", downloadProgress.fractionCompleted);
                                                 progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                                             }
                                         }
                                      destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                          //
//                                          NSLog(@"targetPath:%@\n response:%@",targetPath,response);
//                                          NSString *path = [getCachePath() stringByAppendingPathComponent:[self _getCachePathWithUrl:url]];
//                                          return [NSURL URLWithString:path];
                                          NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                          NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
                                          return [NSURL fileURLWithPath:path];
                                          
                                      }
                                completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
  
                                    if (error) { // 错误
                                        [self handleCallbackWithError:error fail:failure];
                                        if (default_enableInterfaceDebug) {
                                            DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                        }
                                    }else { // 没有错误
                                        if (success) {
                                            success(filePath.absoluteString);
                                            [self _deleteTaskDictWithUrl:url];
                                        }
                                        if (default_enableInterfaceDebug) {
                                            DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                        }
                                    }

                                }];
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            sessionDict[@"partialData"] = nil;
            /**
             *  这里是坑!!!!
             *  sessionTask 的内存地址在这里会改变，与开始启动任务时的Task不一样,所以在这里需要重新存储一遍sessionTask
             */
            #warning 这里是坑!!!!
            sessionDict[@"session"] = sessionTask;
            [self writeToLocalFileWithAllTask:[self allTasks]];
        }
    }
    
    // 启动任务
    [sessionTask resume];
    return sessionTask;
}

#pragma mark -- 取消下载
+ (void)cancelDownloadWithUrl:(NSString *)url {
    
    if (![self _getSessionTaskWithUrl:url]) {
        return;
    }
    
    NSURLSessionDownloadTask *sessionTask = [self _getSessionTaskWithUrl:url];
    [sessionTask cancel];
    sessionTask = nil;
    
    [self _deleteTaskDictWithUrl:url];
}


#pragma mark -- 下载
+ (SKURLSessionDownloadTask *)downloadWithUrl:(NSString *)url
                                    cachePath:(NSString *)cachePath
                                     progress:(SKDownloadProgress)progress
                                      success:(SKResponseSuccess)success
                                      failure:(SKResponseFailure)failure {
    
    if (![self checkUrlWithUrl:url]) {
        return nil;
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    
    // AFHTTPSessionManager *manager = [self _manager];
    
    SKURLSessionDownloadTask *sessionTask = nil;
    

    if (![self _getSessionTaskWithUrl:url]) {  //第一次下载
        
        sessionTask = [manager downloadTaskWithRequest:downloadRequest
                                              progress:^(NSProgress * _Nonnull downloadProgress) {
                                                  if (progress) {
                                                      //NSLog(@"download - %f", downloadProgress.fractionCompleted);
                                                      progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                                                  }
                                              }
                                           destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                               //                                       NSString *path = [getCachePath() stringByAppendingPathComponent:cachePath];
                                               //                                       return [NSURL URLWithString:path];
                                               NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                               NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
                                               return [NSURL fileURLWithPath:path];
                                           }
                                     completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                         
                                         if (error) { // 错误
                                             [self handleCallbackWithError:error fail:failure];
                                             
                                             if (default_enableInterfaceDebug) {
                                                 DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                             }
                                         }else { // 没有错误
                                             if (success) {
                                                 // 删除当前的下载任务
                                                 [self _deleteTaskDictWithUrl:url];
                                                 
                                                 success(filePath.absoluteString);
                                             }
                                             if (default_enableInterfaceDebug) {
                                                 DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                             }
                                         }
                                     }];
        
        // 启动任务
        [sessionTask resume];
        
        if (sessionTask) {
            // 已经下载的局部数据
            NSData *partialData = nil;
            // 包装一个下载任务
            NSMutableDictionary *dicNew = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:url,@"url",
                                           cachePath,@"path",
                                           sessionTask,@"session",
                                           partialData,@"partialData", nil];
            
            // 保存下载任务
            [[self allTasks]addObject:dicNew];
            [self writeToLocalFileWithAllTask:[self allTasks]];
        }

        
    }else { //继续下载
        
        if (![self _getPartialDataWithUrl:url]) {
            return sessionTask;
        }
        
        sessionTask = [manager downloadTaskWithResumeData:[self _getPartialDataWithUrl:url]
                                                 progress:^(NSProgress * _Nonnull downloadProgress) {
                                                     
                                                     if (progress) {
                                                         //NSLog(@"download - %f", downloadProgress.fractionCompleted);
                                                         progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                                                     }
                                                 }
                                              destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                  //
                                                  //                                          NSLog(@"targetPath:%@\n response:%@",targetPath,response);
                                                  //                                          NSString *path = [getCachePath() stringByAppendingPathComponent:[self _getCachePathWithUrl:url]];
                                                  //                                          return [NSURL URLWithString:path];
                                                  NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                                  NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
                                                  return [NSURL fileURLWithPath:path];
                                                  
                                              }
                                        completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                            
                                            if (error) { // 错误
                                                [self handleCallbackWithError:error fail:failure];
                                                if (default_enableInterfaceDebug) {
                                                    DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                                }
                                            }else { // 没有错误
                                                if (success) {
                                                    success(filePath.absoluteString);
                                                    [self _deleteTaskDictWithUrl:url];
                                                }
                                                if (default_enableInterfaceDebug) {
                                                    DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                                }
                                            }
                                            
                                        }];
        
        
        for (NSMutableDictionary *sessionDict in [self allTasks]) {
            if (sessionDict[@"url"] == url) {
                sessionDict[@"partialData"] = nil;
                /**
                 *  这里是坑!!!!
                 *  sessionTask 的内存地址在这里会改变，与开始启动任务时的Task不一样,所以在这里需要重新存储一遍sessionTask
                 */
#warning 这里是坑!!!!
                sessionDict[@"session"] = sessionTask;
                [self writeToLocalFileWithAllTask:[self allTasks]];
            }
        }
        // 启动任务
        [sessionTask resume];
    }
    
    return sessionTask;
}

// 更新本地存储的下载任务
+ (void)updateLocalAllTasks{

//    if ([self readLocalData]) {
//        [[self allTasks] removeAllObjects];
//        [[self allTasks] addObject:[self readLocalData]];
//    }
}

#pragma private Method
/**
 *  是否正在暂停
 */
+(BOOL)isPausingWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return YES;
    }
    return NO;
}

+ (void)_deleteTaskDictWithUrl:(NSString *)url {
    
    __block NSMutableDictionary *sessionD  = nil;
    
    [[self allTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *sessionDict = obj;
        if (sessionDict[@"url"] == url) {
            sessionD = sessionDict;
        }
    }];
    
    [[self allTasks] removeObject:sessionD];
    NSLog(@"[self allTasks] = %@",[self allTasks]);
    
    //[self writeToLocalFileWithAllTask:[self allTasks]];
}

/**
 *  读取本地的任务
 *
 *  @return 本地的任务
 */
+ (NSMutableArray *)readLocalData {
    NSString *documentPath = getCachePath();
    NSString *allTasksPath = [documentPath stringByAppendingPathComponent:@"allTasks.plist"];
    NSMutableArray *allTasks = [NSMutableArray arrayWithContentsOfFile:allTasksPath];
    return  allTasks;
}

/**
 *  根据url返回对应的sessionTask
 */
+ (SKURLSessionDownloadTask *)_getSessionTaskWithUrl:(NSString *)url {
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            NSURLSessionDownloadTask *session = sessionDict[@"session"];
            return session;
        }
    }
    return nil;
    
}

/**
 *  根据url返回对应的sessionTask 本地已经存储的数据
 */
+ (NSData *)_getPartialDataWithUrl:(NSString *)url {
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            NSData *partialData =(NSData *)sessionDict[@"partialData"];
            return partialData;
        }
    }
    return nil;
}

/**
 *  根据url返回对应的sessionTask缓存路径
 */
+ (NSString *)_getCachePathWithUrl:(NSString *)url {
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            NSString *cachePath =(NSString *)sessionDict[@"path"];
            return cachePath;
        }
    }
    return nil;
}

/**
 *  将所有的下载任务存储在本地
 *
 *  @param allTasks 当前所有的下载任务
 */
+ (void)writeToLocalFileWithAllTask:(NSMutableArray *)allTasks{
    NSString *documentPath = getCachePath();
    NSString *allTasksPath = [documentPath stringByAppendingPathComponent:@"allTasks.plist"];
    [allTasks writeToFile:allTasksPath atomically:YES];
}


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
+ (void)handleCallbackWithError:(NSError *)error
                           fail:(SKResponseFailure)fail {

    if ([error code] == NSURLErrorCancelled) { //正在暂停
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
