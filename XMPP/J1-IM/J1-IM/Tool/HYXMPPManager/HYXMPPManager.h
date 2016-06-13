//
//  HYXMPPManager.h
//  J1-IM
//
//  Created by wushangkun on 16/6/7.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYXMPPConfig.h"

/**
 * 判断当前操作是 登录 or 注册
 */
typedef NS_ENUM(NSInteger, XMPPOperation) {
    
    XMPPLoginServerOperation = 10, // 登录操作:认证服务器
    XMPPRegisterServerOperation,   // 注册操作
};


typedef NS_ENUM(NSInteger, XMPPErrorCode) {
    
    XMPPErrorStreamError = -10001,       // 连接错误
    XMPPErrorParamsError,                // 输入的参数错误
    XMPPErrorConnectServerError,         // 连接服务器错误
    XMPPErrorDisConnectServerError,      // 断开服务器错误
    XMPPErrorConnectTimeOutError,        // 连接服务器超时
    XMPPErrorAuthenticateServerError,    // 认证服务器错误
    XMPPErrorRegisterServerError,        // 注册服务器错误
};

typedef NS_ENUM(NSInteger, XMPPResultType) {

    XMPPResultTypeConnecting = 1,  // 连接中...
    XMPPResultTypeNetError,        // 网络不给力
    XMPPResultTypeRegisterSuccess, // 注册成功
    XMPPResultTypeRegisterFailure, // 注册失败
    XMPPResultTypeLoginSuccess,    // 登录成功
    XMPPResultTypeLoginFailure,    // 登录失败
    XMPPResultTypeLogoutSuccess,   // 登出成功
    XMPPResultTypeLogoutFailure,   // 登出失败
};


/**
 *  授权成功
 *
 *  @param result 结果
 */
typedef void(^AuthSuccess)();


/**
 *  授权失败
 *
 *  @param error 错误信息
 */
typedef void(^AuthFailure)(XMPPErrorCode errorCode);


/**
 *  联系人列表有更新
 *
 *  @param result 结果
 */
typedef void(^FriendsUpdate)(BOOL isUpdate);


@interface HYXMPPManager : NSObject
{
    
}

/** 当前的登录用户id */
@property (nonatomic, copy) NSString *jidName;
@property (nonatomic, copy) NSString *userName;

/** XML流 */
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
/** 自动重连 */
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
/** 花名册 */
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
/** 通讯录管理 */
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;


@property (nonatomic,retain)NSMutableArray*subscribeArray;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain,nonatomic)NSMutableDictionary*yanzhengxiaoxi;
//用于记录出席列表
@property(nonatomic,retain)NSMutableDictionary*presentDic;


/**
 *  单例
 */
+ (HYXMPPManager *)sharedManager;


/**
 *  注册
 */
- (void)registerWithUserName:(NSString *)userName
                 passWord:(NSString *)passWord
                  success:(AuthSuccess)success
                  failure:(AuthFailure)failure;

/**
 *  登录
 */
- (void)loginWithUserName:(NSString *)userName
                 passWord:(NSString *)passWord
                  success:(AuthSuccess)success
                  failure:(AuthFailure)failure;
/**
 *  联系人列表
 *
 *  @param friendsUpdate 联系人列表有更新block
 *  依次为：[haoyou,guanzhu,beiguanzhu,duifang];
 */
- (NSArray *)friendList:(void(^)(BOOL isUpdate))friendsUpdate;


/**
 *  登出
 */
- (void)logout;

/**
 *  销毁
 */
- (void)teardownXmppStream;


/** 授权成功 */
@property (nonatomic, copy) AuthSuccess authSuccess;
/** 授权失败 */
@property (nonatomic, copy) AuthFailure authFailure;
/** 联系人列表有更新 */
@property (nonatomic, copy) void(^friendsUpdate)(BOOL isUpdate);
@end
