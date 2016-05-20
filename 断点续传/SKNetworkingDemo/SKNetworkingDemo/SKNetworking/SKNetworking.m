//
//  SKNetworking.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SKNetworking.h"

static NSString *default_baseUrl = nil;

@implementation SKNetworking

+ (NSString *)baseUrl{
   return  default_baseUrl;
}

+ (SKURLSessionTask *)downloadWithUrl:(NSString *)url
                            cachePath:(NSString *)cachePath
                             progress:(SKDownloadProgress)progress
                              success:(SKResponseSuccess)success
                              failure:(SKResponseFailure)failure{
//    if (![self baseUrl]) {
//        // nil
//        <#statements#>
//    }






}
@end
