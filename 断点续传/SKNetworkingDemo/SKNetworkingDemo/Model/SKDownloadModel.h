//
//  SKDownloadModel.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKDownloadModel : NSObject
/** title */
@property (nonatomic, strong) NSString *name;
/** 下载链接 */
@property (nonatomic, strong) NSString *linkUrl;
/** 缓存路径 */
@property (nonatomic, strong) NSString *destinationPath;


@end
