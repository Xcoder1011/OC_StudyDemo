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
typedef void(^Failure)(NSError *error);


@interface HYXMPPManager : NSObject{

}

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
 *  登录
 */
- (void)loginWithUserName:(NSString *)userName
                 passWord:(NSString *)passWord
                  success:(Success)success
                  failure:(Failure)failure;



@end
