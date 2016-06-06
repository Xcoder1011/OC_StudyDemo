//
//  HYDatabase.h
//  Wireless
//
//  Created by j1macteam on 14-7-22.
//  Copyright (c) 2014年 j1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
//#import "FMDatabase.h"
#import "FMDB.h"
#import "sql.h"


#define dbName          @"J1IM_DB"  //数据库名字,和andior取名一样
#define dbArea          @"dbArea"
#define TABLE_USER      @"user"
#define MEDICREMINDER   @"medicreminder"
#define TABEL_GOODS_CATEGORY  @"goods_category"
#define MALL_HOME               @"home_page"
#define TABLE_SESSION @"sessionmsg"
#define DISEASE_BAIKE @"disease_baike"
#define HISTORY_SEARCH @"history_search"
#define COMMON_CATEGORY @"common_category"
#define TABLE_SIGNINPRE @"signInPre"
#define TABLE_J1MESSAGE @"J1Message"

static NSInteger DATABASE_VERSION = 10;

@interface HYDatabase : NSObject
{
    FMDatabase *db;
    FMDatabase *dbProvinceAndCity; //省市
    
}

@property (nonatomic ,assign) BOOL isDBopen;
@property (nonatomic ,assign) BOOL isDBProvinceOpen;


+(HYDatabase *)sharedManager;
- (void)createEditableCopyOfDatabaseIfNeeded;
-(void)deleteOldTable;
-(FMResultSet *)userQueryData:(NSString *)inquerySql objects:(NSArray *)objects;
-(void)insertOrDeleteData:(NSString *)sql objects:(NSArray*)objects;
-(void)deleteSheet:(NSString *)deleteSql;
-(NSMutableArray *)trimStringFromDataBase:(NSString*)strDataBase;
-(NSMutableArray *)queryProvinces;
-(NSMutableArray *)queryCitysFromProvinceId:(NSNumber *)pid;
-(NSMutableArray *)queryAreaFromCityId:(NSNumber *)cid;
-(NSMutableArray *)queryAllSignInPreFromDataNums;
-(NSMutableArray *)queryCurrentMonthSignInPreFromDataNumsYear:(NSString *)currentYear  AndMonth:(NSString *)currentMonth;
@end
