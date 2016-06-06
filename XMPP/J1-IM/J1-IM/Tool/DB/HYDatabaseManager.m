//
//  HYDatabaseManager.m
//  J1-IM
//
//  Created by wushangkun on 16/2/5.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "HYDatabaseManager.h"

@implementation HYDatabaseManager

static id _instance;
+(instancetype)sharedDataManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //
        _instance = [[self allocWithZone:NULL]init];
        [_instance createDatabaseIfNeeded];
    });
    return _instance;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [HYDatabaseManager sharedDataManager];
}


-(void)createDatabaseIfNeeded{
    
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *path = [document stringByAppendingPathComponent:@"J1-IM.sqlite"];
    self.dbPath = path;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.dbPath]) {
        NSLog(@"表不存在，创建表");
        db = [FMDatabase databaseWithPath:self.dbPath];
        if (![db open]) {
            NSLog(@"数据库打开失败！");
            self.isOpen = NO;
            return;
        }
        self.isOpen = YES;
    }
}

// 插入、删除、修改数据
- (void)updateDataBySql:(NSString *)sql withObjects:(NSArray *)objects{
    
    
    

}



@end
