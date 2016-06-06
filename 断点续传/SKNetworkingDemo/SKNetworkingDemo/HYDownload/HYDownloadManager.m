//
//  HYDownloadManager.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/31.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "HYDownloadManager.h"


@interface HYDownloadManager ()

/** 保存有的下载任务，key为url */
@property (nonatomic, strong) NSMutableDictionary *tasksDict;
/** 保存所有下载相关信息sessionModel */
@property (nonatomic, strong) NSMutableDictionary *sessionModelsDict;
/** 所有本地存储的所有下载信息数据数组 */
@property (nonatomic, strong) NSMutableArray *sessionModelsArray;
/** 下载完成的模型数组*/
@property (nonatomic, strong) NSMutableArray *downloadedArray;
/** 下载中的模型数组*/
@property (nonatomic, strong) NSMutableArray *downloadingArray;

@end

@implementation HYDownloadManager



#pragma mark -- 下载
- (void)downloadWithUrl:(NSString *)url
              cachePath:(NSString *)cachePath
               progress:(HYDownloadProgressBlock)progress
                  state:(HYDownloadStateBlock)state {
    
    if (![self checkUrlWithUrl:url]) {
        return ;
    }
    
    // 有可能完成
    
    // 有可能是暂定状态
    
    
    // 创建缓存目录
    [self createCacheDirectory];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession *sesion = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    
    // 创建流
    NSOutputStream * stream = [NSOutputStream outputStreamToFileAtPath:_getFileFullPath(url) append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",_getFileDownloadedLength(url)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    //创建一个downloadTask
    NSURLSessionDownloadTask *task = [sesion downloadTaskWithRequest:request];
    
    [task setValue:url  forKey:@"taskIdentifier"];
    
    [self.tasksDict setValue:task forKey:url];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:_getFileFullPath(url)]) { //本地不存在文件,保存文件
        HYDownloadModel *sessionModel = [[HYDownloadModel alloc]init];
        sessionModel.linkUrl = url;
        sessionModel.progressBlock = progress;
        sessionModel.stateBlock = state;
        sessionModel.stream = stream;
        sessionModel.startTime = [NSDate date];
        sessionModel.fileName = [[url componentsSeparatedByString:@"/"]lastObject];
        [self.sessionModelsDict setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
        
        
    } else {  //存在文件
    
    }
    
    
    
    
    
    
    
    

    
    
    


}



#pragma mark -- Private Method

// 文件已经下载的长度
static inline NSInteger _getFileDownloadedLength(NSString *url) {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_getFileFullPath(url) error:nil];
    return [attributes[NSFileSize] integerValue];
}

/**
 *  文件的存放路径（caches）
 *  内联函数 : 可减少cpu的系统开销
 */
static inline NSString *_getFileFullPath(NSString *url) {
    return [_getCacheDirectory() stringByAppendingPathComponent:[[url componentsSeparatedByString:@"/"] lastObject]] ;
}

// 缓存主目录
static inline NSString *_getCacheDirectory() {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"HYDownloadCache"];
}



//- (NSArray *)getSessionModels {
//
//    // 文本信息
//    NSArray *sessionModels = [NSKeyedUnarchiver unarchiveObjectWithFile:<#(nonnull NSString *)#>]
//    
//}


/**
 *  创建缓存主目录
 */
- (void)createCacheDirectory {
    // 缓存主目录
    NSString *cachePath = _getCacheDirectory();
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (BOOL)isCompletedDownloadTaskWithUrl:(NSString *)url {
    return NO;
}



// 检测URL是否有效
- (BOOL)checkUrlWithUrl:(NSString *)url{
    if (!_baseUrl) {
        // nil
        if (![NSURL URLWithString:url]) {
            DLog(@"url无效，可能是URL中有中文,请尝试Encode URL");
            return NO;
        }
    }else {
        if (![NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_baseUrl,url]]) {
            DLog(@"url无效，可能是URL中有中文,请尝试Encode URL");
            return NO;
        }
    }
    return YES;
}




#pragma mark -- setter getter 

- (NSMutableDictionary *)tasksDict {
    if (!_tasksDict) {
        _tasksDict = @{}.mutableCopy;
    }
    return  _tasksDict;
}

- (NSMutableDictionary *)sessionModelsDict {
    if (!_sessionModelsDict) {
        _sessionModelsDict = @{}.mutableCopy;
    }
    return  _sessionModelsDict;
}

- (NSMutableArray *)sessionModelsArray {
    if (!_sessionModelsArray) {
        _sessionModelsArray = @[].mutableCopy;
       // [_sessionModelsArray addObjectsFromArray:<#(nonnull NSArray *)#>]
    }
    return _sessionModelsArray;
}

- (NSMutableArray *)downloadedArray {

    if (_downloadedArray) {
        _downloadedArray = @[].mutableCopy;
    }
    return _downloadedArray;
}

- (void)setBaseUrl:(NSString *)baseUrl {
    _baseUrl = baseUrl;
}


@end
