//
//  sql.h
//  Wireless
//
//  Created by j1macteam on 14-7-31.
//  Copyright (c) 2014年 j1. All rights reserved.
//

#ifndef Wireless_sql_h
#define Wireless_sql_h

#define BANNERLIST @"bannerList"
#define ACTIVITYGOODLIST @"activityGoodList"
#define HOTRECOMMENDGOODLIST @"hotRecommendGoodList"
#define BOTTOMCATEGORYLIST @"bottomCategoryList"
#define BOTTOMCATEGORYGOODLIST @"bottomCategoryGoodList"

//=============用户=====================
extern NSString * const INSERT_USER_SQL;
extern NSString * const SELECT_USER_SQL ;
extern NSString * const DELETE_USER_SQL ;
extern NSString * const SELECT_USERS_SQL ;
extern NSString * const DELETE_USERS_SQL ;

//=============用药提醒=====================
extern NSString * const SELECT_MEDIC_REMINDER_SQL;
extern NSString * const DELETE_MEDIC_REMINDER_SQL;
extern NSString * const INSERT_MEDIC_REMINDER_SQL;
extern NSString * const DELETE_MEDIC_REMINDER_SQL_WITH_ID;

//=============商品分类=====================
extern NSString * const SELECT_CATEGORY_SQL;
extern NSString * const DELETE_CATEGORY_SQL;
extern NSString * const INSERT_CATEGORY_SQL;

//=============首页分类=====================
extern NSString *const SELECT_HOMEPAGE_SQL;
extern NSString *const DELECT_HOMEPAGE_SQL;
extern NSString *const INSERT_HOMEPAGE_SQL;

// ===========================================咨询－会话列表======================================
extern NSString *const INSERT_SESSION_SQL;
extern NSString *const SELECT_SESSION_SQL;
extern NSString *const SELECT_SESSION_SQL_BY_ID;
extern NSString *const DELETE_SESSION_SQL;
extern NSString *const UPDATE_SESSION_SQL_READAMOUNT;
extern NSString *const DELETE_SESSION_SQL_BY_ID;

// ===========================================疾病百科======================================
extern NSString *const SELECT_DISEASE_BAIKE_SQL;
extern NSString *const INSERT_DISEASE_BAIKE_SQL;
extern NSString *const DELETE_DISEASE_BAIKE_SQL;

// ===========================================搜索历史======================================
extern NSString *const SELECT_HISTORYSEARCH_SQL;
extern NSString *const INSERT_HISTORYSEARCH_SQL;
extern NSString *const DELETE_HISTORYSEARCH_SQL;
//============================================补充签到======================================
extern NSString *const SELECT_SIGININPRE_SQL;
extern NSString *const INSERT_SIGININPRE_SQL;
extern NSString *const DELETE_SIGININPRE_SQL;

// ===========================================常用分类======================================
extern NSString *const SELECT_COMMONCATEGORY_SQL;
extern NSString *const INSERT_COMMONCATEGORY_SQL;
extern NSString *const DELETE_COMMONCATEGORY_SQL;
extern NSString *const DELETE_COMMONCATEGORY_SQLFROMTHIREDCATEGORY;

// ===========================================地址省市区======================================
extern NSString *const SELECT_ADDRESSPROVINCE_SQL;
extern NSString *const SELECT_ADDRESSCITY_SQL;
extern NSString *const SELECT_ADDRESSAREA_SQL;
// ===========================================签到======================================
extern NSString *const INSERT_SIGININPRE_SQL;
extern NSString *const SELECT_SIGININPRE_SQL;
extern NSString *const DELETE_SIGININPRE_SQL;
extern NSString *const SELECT_SIGININPRE_SQLCURRENTMONTH;

// ===========================================J1IM_Message======================================
extern NSString *const INSERT_J1MESSAGE_SQL;
extern NSString *const SELECT_J1MESSAGE_SQL;
extern NSString *const SELECT_J1MESSAGE_BYDATE_SQL;
extern NSString *const UPDATE_J1MESSAGE_SQL;
extern NSString *const DELETE_J1MESSAGE_SQL;
#endif

