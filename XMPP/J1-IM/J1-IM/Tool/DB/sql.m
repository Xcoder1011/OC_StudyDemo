//
//  sql.m
//  Wireless_Sender
//
//  Created by 李博 on 14-8-14.
//  Copyright (c) 2014年 j1. All rights reserved.
//

#ifndef Wireless_Sender_sql_m
#define Wireless_Sender_sql_m


//
//  sql.h
//  Wireless
//
//  Created by j1macteam on 14-7-31.
//  Copyright (c) 2014年 j1. All rights reserved.
//

#ifndef Wireless_sql_h
#define Wireless_sql_h

//=============用户=====================
NSString * const INSERT_USER_SQL = @"INSERT INTO user (user_id, user, user_token) values (?, ?, ?)";
NSString * const SELECT_USER_SQL = @"SELECT * FROM user where user_id = ?";
NSString * const DELETE_USER_SQL = @"DELETE FROM user where user_id = ?";
NSString * const SELECT_USERS_SQL = @"SELECT * FROM user";
NSString * const DELETE_USERS_SQL = @"DELETE FROM user";

//用药提醒
NSString * const SELECT_MEDIC_REMINDER_SQL = @"SELECT * FROM medicreminder";
NSString * const DELETE_MEDIC_REMINDER_SQL = @"DELETE FROM medicreminder";
//NSString * INSERT_MEDIC_REMINDER_SQL = @"INSERT INTO medicreminder (identity_NO,drug_name, drug_user, drug_account,drug_times,state,repeatType) values (?,?,?,?,?,?,?)";
NSString * const INSERT_MEDIC_REMINDER_SQL = @"INSERT INTO medicreminder (identity_NO ,drug_name, drug_user, drug_account,drug_times, state, repeatType,date) values (?,?,?,?,?,?,?,?)";

NSString * const DELETE_MEDIC_REMINDER_SQL_WITH_ID = @"DELETE FROM medicreminder where identity_NO = ?";

//=============商品分类=====================
NSString * const SELECT_CATEGORY_SQL = @"select * from goods_category";
NSString * const DELETE_CATEGORY_SQL = @"delete from goods_category";
NSString * const INSERT_CATEGORY_SQL = @"insert into goods_category (goods_categories) values (?)";

//=============首页=====================
NSString *const SELECT_HOMEPAGE_SQL = @"select * from home_page";
NSString *const DELECT_HOMEPAGE_SQL = @"DELETE FROM home_page";
NSString * const INSERT_HOMEPAGE_SQL = @"insert into home_page (good_type,goods) values (?,?)";

// ===========================================大厅－会话列表======================================
NSString * const INSERT_SESSION_SQL = @"INSERT INTO sessionmsg (user_id, session_id, unread_amount, session_type, sessionMessage) values (?, ?, ?, ?, ?)";
NSString * const SELECT_SESSION_SQL = @"SELECT * FROM sessionmsg";
NSString * const SELECT_SESSION_SQL_BY_ID = @"SELECT * FROM sessionmsg where user_id = ? and session_id = ?";
NSString * const DELETE_SESSION_SQL = @"DELETE FROM sessionmsg";//删除所有
NSString * const UPDATE_SESSION_SQL_READAMOUNT = @"UPDATE sessionmsg set unread_amount = ?,sessionMessage = ? where session_id = ? and user_id = ?";
NSString * const DELETE_SESSION_SQL_BY_ID = @"DELETE FROM sessionmsg where user_id = ? and session_id = ?";

// ===========================================疾病百科======================================
NSString *const SELECT_DISEASE_BAIKE_SQL = @"SELECT * FROM disease_baike";
NSString *const INSERT_DISEASE_BAIKE_SQL = @"insert into disease_baike(dis_department) values (?)";
NSString *const DELETE_DISEASE_BAIKE_SQL = @"delete from disease_baike";

// ===========================================搜索历史======================================
NSString *const SELECT_HISTORYSEARCH_SQL =@"SELECT * FROM history_search";
NSString *const INSERT_HISTORYSEARCH_SQL =@"insert or replace into history_search(name, detail, targetUrl) values (?,?,?)";
NSString *const DELETE_HISTORYSEARCH_SQL =@"delete from history_search";

// ===========================================签到======================================
NSString *const INSERT_SIGININPRE_SQL =@"insert or replace into signInPre(dateNums,year,month,day) values (?,?,?,?)";
NSString *const SELECT_SIGININPRE_SQL =@"SELECT * FROM signInPre";
NSString *const SELECT_SIGININPRE_SQLCURRENTMONTH =@"SELECT * FROM signInPre where year = ? and month = ?";
NSString *const DELETE_SIGININPRE_SQL =@"delete from signInPre";

// ===========================================常用分类======================================
NSString *const SELECT_COMMONCATEGORY_SQL =@"SELECT * FROM common_category ORDER BY id DESC LIMIT 6";
NSString *const INSERT_COMMONCATEGORY_SQL =@"insert into common_category(thirdLevelCategory) values (?)";
NSString *const DELETE_COMMONCATEGORY_SQL =@"delete from common_category";
NSString *const DELETE_COMMONCATEGORY_SQLFROMTHIREDCATEGORY =@"delete from common_category where thirdLevelCategory = ?";

// ===========================================地址省市区======================================
NSString *const SELECT_ADDRESSPROVINCE_SQL =@"SELECT *FROM province";
NSString *const SELECT_ADDRESSCITY_SQL =@"SELECT * FROM city where provinceId =?";
NSString *const SELECT_ADDRESSAREA_SQL =@"SELECT * FROM area where cityId =?";

// ===========================================J1IM_Message======================================
NSString *const INSERT_J1MESSAGE_SQL =@"insert or replace into J1Message values (?,?,?,?,?)";
NSString *const SELECT_J1MESSAGE_SQL =@"SELECT * FROM J1Message where messageFrom=? and messageTo=?";

NSString *const SELECT_J1MESSAGE_BYDATE_SQL = @"SELECT * FROM J1Message where messageFrom=? or messageTo=? order by messageDate desc limit ?";

NSString *const UPDATE_J1MESSAGE_SQL =@"update J1Message set messageContent=?, messageDate=? where messageTo=? and messageFrom=?";
NSString *const DELETE_J1MESSAGE_SQL =@"delete from J1Message";

#endif
#endif
