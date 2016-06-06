//
//  HYDatabase.m
//  Wireless
//
//  Created by j1macteam on 14-7-22.
//  Copyright (c) 2014年 j1. All rights reserved.
//

#import "HYDatabase.h"
#define kDATABASE_VERSION  @"DATABASE_VERSION"
static HYDatabase *shareManager = nil;

@implementation HYDatabase

+(HYDatabase *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        shareManager = [[self alloc] init];
        [shareManager createEditableCopyOfDatabaseIfNeeded];
        [shareManager copyAreaDatabaseIfNeeded];
    });
    return shareManager;
}

- (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:dbName];
    NSLog(@"＝＝＝%@",path);
	return path;
}
- (void)copyAreaDatabaseIfNeeded {
//    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *path = [documentDirectory stringByAppendingPathComponent:dbArea];
//    NSFileManager *file =[NSFileManager defaultManager];
//    if ([file fileExistsAtPath:path]) {
//        dbProvinceAndCity =[FMDatabase databaseWithPath:path];
//        return ;
//    }
//    NSString *strDB =[[NSBundle mainBundle] pathForResource:@"area" ofType:@"db"];
//    [file copyItemAtPath:strDB toPath:path error:nil];
//    dbProvinceAndCity =[FMDatabase databaseWithPath:path];
}
- (void)createEditableCopyOfDatabaseIfNeeded {
	
    NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    db = [FMDatabase databaseWithPath:writableDBPath];//不存在，则自动创建
    
    NSUserDefaults *userDefault =[NSUserDefaults standardUserDefaults];
    if (DATABASE_VERSION ==[userDefault integerForKey:kDATABASE_VERSION]) {
       
    }
    else {
        [userDefault setInteger:DATABASE_VERSION forKey:kDATABASE_VERSION];
        [userDefault synchronize];
        [self deleteOldTable];
    }

    if (![db open]) {
        NSLog(@"Could not open db");
        self.isDBopen = NO;
        return;
    }
    self.isDBopen = YES;
    
    
    //定义创建用户表的SQL语句
    NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@  (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, user VARCHAR, user_token VARCHAR);",TABLE_USER];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建用户表失败");
        [db close];
        return;
    }
    //用药提醒表的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (identity_NO INTEGER,drug_name VARCHAR, drug_user VARCHAR, drug_account VARCHAR,drug_times VARCHAR, state VARCHAR, repeatType VARCHAR,date VARCHAR);",MEDICREMINDER];
//    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (identity_NO INTEGER,medic_reminder VARCHAR);",MEDICREMINDER];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建用药提醒表失败");
        [db close];
        return;
    }
    
    //定义创建商品分类的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@  (id INTEGER PRIMARY KEY AUTOINCREMENT, goods_categories VARCHAR);",TABEL_GOODS_CATEGORY];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建商品分类表失败");
        [db close];
        return;
    }
    
    //定义创建首页的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@  (good_type VARCHAR,goods VARCHAR);",MALL_HOME];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建首页表失败");
        [db close];
        return;
    }
    
    //定义创建消息会话的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, session_id VARCHAR, unread_amount INTEGER, session_type INTEGER, sessionMessage VARCHAR);",TABLE_SESSION];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建疾病百科表失败");
        [db close];
        return;
    }

    //定义创建疾病百科的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@  (dis_department VARCHAR);",DISEASE_BAIKE];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建疾病百科表失败");
        [db close];
        return;
    }
    //定义创建历史搜索的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@  (name VARCHAR PRIMARY KEY, detail VARCHAR, targetUrl VARCHAR);",HISTORY_SEARCH];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建搜索历史表失败");
        [db close];
        return;
    }
    //定义创建历史搜索的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@  (id INTEGER PRIMARY KEY AUTOINCREMENT,thirdLevelCategory VARCHAR);",COMMON_CATEGORY];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"创建常用分类表失败");
        [db close];
        return;
    }
    //定义创建补充签到的SQL语句
    createSQL=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(dateNums TEXT PRIMARY KEY ,year TEXT, month TEXT, day TEXT);",TABLE_SIGNINPRE];
    if ([db executeUpdate:createSQL]==NO) {
        NSLog(@"创建补充签到表失败");
        [db close];
        return;
    }
    
    //定义创建J1IM_Message的SQL语句
    createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (messageFrom,messageTo,messageContent,messageDate,messageType);",TABLE_J1MESSAGE];
    if ([db executeUpdate:createSQL] == NO) {
        NSLog(@"J1Message消息表创建失败！");
        [db close];
        return;
    }
    return;
}

//若版本号发生变化就删除掉先前的表
-(void)deleteOldTable
{
    if ([db open]) {
        [db beginTransaction];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",TABLE_USER]];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",MEDICREMINDER]];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",TABEL_GOODS_CATEGORY]];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",MALL_HOME]];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",TABLE_SESSION]];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",DISEASE_BAIKE]];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",HISTORY_SEARCH]];
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",COMMON_CATEGORY]];
        [db commit];
        [db close];
    }
    [self createEditableCopyOfDatabaseIfNeeded];
}

//查询数据 //直接返回游标，在函数调用的地方
-(FMResultSet *)userQueryData:(NSString *)inquerySql objects:(NSArray *)objects
{
    @synchronized(self)
    {
        if (inquerySql == nil) {
            return nil;
        }
        FMResultSet *rs = nil;
        if ([db open]) {
            
            if (objects == nil) {
                rs = [db executeQuery:inquerySql];
            }
            else
            {
                rs = [db executeQuery:inquerySql withArgumentsInArray:objects];
            }
            return rs;
        }
        return nil;
    }
}

//数据插入,删除
-(void)insertOrDeleteData:(NSString *)sql objects:(NSArray*)objects
{
    @synchronized(self)
    {
        if ([db open]) {
            if (sql == nil) {
                return;
            }
            [db beginTransaction];
            if (objects == nil) {
                [db executeUpdate:sql];
            }
            else
            {
                [db executeUpdate:sql withArgumentsInArray:objects];
            }
            [db commit];
            [db close];
        }
    }
}

//数据删除(整个表)
-(void)deleteSheet:(NSString *)deleteSql
{
    @synchronized(self)
    {
        if ([db open]) {
            [db beginTransaction];
            [db executeUpdate:deleteSql];
            [db commit];
            [db close];
        }
    }
}

//分割数据库中的字符串结构
-(NSMutableArray *)trimStringFromDataBase:(NSString*)strDataBase
{
    NSString *strFirst = nil;
    NSMutableArray *returnArray = [NSMutableArray array];
    
    NSArray *array = [strDataBase componentsSeparatedByString:@"\n"];  //与换行符来分割
    //去除第一个和最后一个因为这两个是左右括号,array中的数据作为NSString数组
    for (int i = 1; i < [array count] - 1; i++) {
        
        strFirst = (NSString *)array[i];
        NSString *strSecond =  [strFirst stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (i != [array count] - 2)
        {
            //数据库中的数据返回有逗号为分隔符
            if ([strSecond hasSuffix:@","]) {
                NSString *strThird = [strSecond substringToIndex:[strSecond length] - 1];
                [returnArray addObject:strThird];
            }
            
        }
        else
        {
            [returnArray addObject:strSecond];
        }        
    }
    return returnArray;
}
-(NSMutableArray *)queryProvinces {
    FMResultSet *resultSet = [shareManager userQueryAreaData:SELECT_ADDRESSPROVINCE_SQL objects:nil];
    NSMutableArray *arrCitys =[[NSMutableArray alloc] init];
    while ([resultSet next]) {
        NSMutableDictionary *dicCity =[[NSMutableDictionary alloc] init];
        [dicCity setObject:[NSNumber numberWithInteger:[resultSet intForColumn:@"id"]] forKey:@"id"];
        [dicCity setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
        [arrCitys addObject:dicCity];
    }
    return arrCitys;

}
-(NSMutableArray *)queryCitysFromProvinceId:(NSNumber *)pid {
    FMResultSet *resultSet = [shareManager userQueryAreaData:SELECT_ADDRESSCITY_SQL objects:@[pid]];
    NSMutableArray *arrProvinces =[[NSMutableArray alloc] init];
    while ([resultSet next]) {
        NSMutableDictionary *dicProvince =[[NSMutableDictionary alloc] init];
        [dicProvince setObject:[NSNumber numberWithInteger:[resultSet intForColumn:@"id"]] forKey:@"id"];
        [dicProvince setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
        [arrProvinces addObject:dicProvince];
    }
    return arrProvinces;
}

-(NSMutableArray *)queryAreaFromCityId:(NSNumber *)cid {
    FMResultSet *resultSet = [shareManager userQueryAreaData:SELECT_ADDRESSAREA_SQL objects:@[cid]];
    NSMutableArray *arrProvinces =[[NSMutableArray alloc] init];
    while ([resultSet next]) {
        NSMutableDictionary *dicProvince =[[NSMutableDictionary alloc] init];
        [dicProvince setObject:[NSNumber numberWithInteger:[resultSet intForColumn:@"id"]] forKey:@"id"];
        [dicProvince setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
        [arrProvinces addObject:dicProvince];
    }
    return arrProvinces;
}

-(NSMutableArray *)queryAllSignInPreFromDataNums{
    FMResultSet *resultSet =[shareManager userQueryData:SELECT_SIGININPRE_SQL objects:nil];
    NSMutableArray *arraySignins=[[NSMutableArray alloc] init];
    while ([resultSet next]) {
//        NSMutableDictionary *dicSign=[[NSMutableDictionary alloc] init];
//        [dicSign setObject:[resultSet stringForColumn:@"dateNums"] forKey:@"dateNums"];
//        [dicSign setObject:[resultSet stringForColumn:@"year"] forKey:@"year"];
//        [dicSign setObject:[resultSet stringForColumn:@"month"] forKey:@"month"];
//        [dicSign setObject:[resultSet stringForColumn:@"day"] forKey:@"day"];
        [arraySignins addObject:[NSString stringWithFormat:@"%@",[resultSet stringForColumn:@"dateNums"]]];
    }
    return arraySignins;
}
-(NSMutableArray *)queryCurrentMonthSignInPreFromDataNumsYear:(NSString *)currentYear  AndMonth:(NSString *)currentMonth {
    FMResultSet *resultSet =[shareManager userQueryData:SELECT_SIGININPRE_SQLCURRENTMONTH objects:@[currentYear,currentMonth]];
    NSMutableArray *arraySignins=[[NSMutableArray alloc] init];
    while ([resultSet next]) {
        NSMutableDictionary *dicSign=[[NSMutableDictionary alloc] init];
        [dicSign setObject:[resultSet stringForColumn:@"dateNums"] forKey:@"dateNums"];
        [dicSign setObject:[resultSet stringForColumn:@"year"] forKey:@"year"];
        [dicSign setObject:[resultSet stringForColumn:@"month"] forKey:@"month"];
        [dicSign setObject:[resultSet stringForColumn:@"day"] forKey:@"day"];
        [arraySignins addObject:dicSign];
    }
    return arraySignins;

}
//查询数据 //直接返回游标，在函数调用的地方
-(FMResultSet *)userQueryAreaData:(NSString *)inquerySql objects:(NSArray *)objects
{
    @synchronized(self)
    {
        if (inquerySql == nil) {
            return nil;
        }
        FMResultSet *rs = nil;
        if ([dbProvinceAndCity open]) {
            
            if (objects == nil) {
                rs = [dbProvinceAndCity executeQuery:inquerySql];
            }
            else
            {
                rs = [dbProvinceAndCity executeQuery:inquerySql withArgumentsInArray:objects];
            }
            return rs;
        }
        return nil;
    }
}

@end
