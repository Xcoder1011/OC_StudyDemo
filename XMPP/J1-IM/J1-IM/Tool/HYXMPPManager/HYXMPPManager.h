//
//  HYXMPPManager.h
//  J1-IM
//
//  Created by wushangkun on 16/6/7.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYXMPPConfig.h"


typedef NS_ENUM(NSInteger, XMPPErrorCode)
{
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
 *  成功回调
 *
 *  @param result 结果
 */
typedef void(^Success)(id result);
/**
 *  失败回调
 *
 *  @param error 错误信息
 */
typedef void(^Failure)(XMPPErrorCode *errorCode);


@interface HYXMPPManager : NSObject{

}


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




/** 当前的登录用户id */
@property (nonatomic, copy) NSString *jidName;
@property (nonatomic, copy) NSString *userName;

/** XML流 */
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
/** 自动重连 */
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnet;
/** 花名册 */
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;


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
 *  登录
 */
- (void)loginWithUserName:(NSString *)userName
                 passWord:(NSString *)passWord
               loginBlock:(void(^)(XMPPResultType))loginBlock;

/** 登录的回调 */
@property (nonatomic, copy) void(^loginBlock)(XMPPResultType);


/** 授权成功 */
@property (nonatomic, copy) AuthSuccess authSuccess;
/** 授权失败 */
@property (nonatomic, copy) AuthFailure authFailure;
@end
