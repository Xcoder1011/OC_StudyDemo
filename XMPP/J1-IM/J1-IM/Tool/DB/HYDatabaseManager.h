//
//  HYDatabaseManager.h
//  J1-IM
//
//  Created by wushangkun on 16/2/5.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface HYDatabaseManager : NSObject{
    FMDatabase *db;
}

@property (nonatomic,strong) NSString *dbPath;
@property (nonatomic,assign) BOOL  isOpen;

+(instancetype)sharedDataManager;

//除查询以外的所有操作，都称为“更新”,
//如：create、drop、insert、update、delete等操作，使用executeUpdate:方法执行更新：
- (void)updateDataBySql:(NSString *)sql withObjects:(NSArray *)objects;

@end
