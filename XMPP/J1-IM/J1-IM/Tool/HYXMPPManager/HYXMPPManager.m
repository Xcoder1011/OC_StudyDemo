//
//  HYXMPPManager.m
//  J1-IM
//
//  Created by wushangkun on 16/6/7.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "HYXMPPManager.h"

@interface HYXMPPManager () <XMPPRosterDelegate,XMPPStreamDelegate>

@property (nonatomic, assign) XMPPOperation xmppOperation;

@end

@implementation HYXMPPManager


+ (HYXMPPManager *)sharedManager {
    static HYXMPPManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[HYXMPPManager alloc]init];
    });
    return _manager;
}

- (instancetype)init {

    self = [super init];
    if (self) {
        [self setupStream];
    }
    return self;
}


/**
 *  配置XML流
 */
- (void)setupStream {
    
    _xmppStream = [[XMPPStream alloc]init];

#if !TARGET_IPHONE_SIMULATOR
    {
        _xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    _xmppStream.hostName = kServerName;
    _xmppStream.hostPort = kPort;
    
    //自动重连
    _xmppReconnect = [[XMPPReconnect alloc]init];
    _xmppReconnect.autoReconnect = YES;
    
    //通讯录管理
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    
    //花名册
    _xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:_xmppRosterStorage];
    _xmppRoster.autoFetchRoster = YES;
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [_xmppReconnect activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppReconnect activate:_xmppStream];

 
    [_xmppRosterStorage mainThreadManagedObjectContext];
}

#pragma mark --  注册

- (void)registerWithUserName:(NSString *)userName
                    passWord:(NSString *)passWord
                     success:(AuthSuccess)success
                     failure:(AuthFailure)failure{
    
    _authSuccess = success;
    _authFailure = failure;
    _xmppOperation = XMPPRegisterServerOperation;

    if (!userName || !passWord ) {
        _authFailure(XMPPErrorParamsError);
        return ;
    }
    
    if ([_xmppStream isConnecting]) {
        return;
    }
    
    UserOperation *user = [UserOperation shareduser];
    NSString *hostName = user.hostUrl;
    self.jidName = [userName stringByAppendingFormat:@"@%@",hostName];
    
//    self.jidName = [userName stringByAppendingFormat:@"@%@",kServerName];
    self.userName = userName;
    
    // resource: iPhone土豪金
    XMPPJID *xmppJID = [XMPPJID jidWithUser:userName domain:hostName resource:@"iOS"];
    [_xmppStream setMyJID:xmppJID];
    
    NSError *error = nil;
    
    if ([_xmppStream isConnected]) {
        [_xmppStream authenticateWithPassword:passWord error:&error];
        
        if (error) {
            _authFailure(XMPPErrorRegisterServerError);
        }
        return;
    }
    
    if (![_xmppStream connectWithTimeout:kConnectTimeOut error:&error]) {
        if (error) {
            failure(XMPPErrorConnectServerError);
            return;
        }
    }

}


#pragma mark --  登录

- (void)loginWithUserName:(NSString *)userName
                 passWord:(NSString *)passWord
                  success:(AuthSuccess)success
                  failure:(AuthFailure)failure;{
    _authSuccess = success;
    _authFailure = failure;
    _xmppOperation = XMPPLoginServerOperation;

    if (!userName || !passWord ) {
        _authFailure(XMPPErrorParamsError);
        return ;
    }
    
    if ([_xmppStream isConnecting]) {
        return;
    }
    
    if ([_xmppStream isConnected] && [_xmppStream isAuthenticated]) {
        _authSuccess();
        return;
    }
    
    UserOperation *user = [UserOperation shareduser];
    NSString *hostName = user.hostUrl;
    self.jidName = [userName stringByAppendingFormat:@"@%@",hostName];
    
//    self.jidName = [userName stringByAppendingFormat:@"@%@",kServerName];
    self.userName = userName;
    
    [self.xmppStream setMyJID:[XMPPJID jidWithString:self.jidName resource:@"iOS"]];
    
    NSError *error = nil;
    
    if ([_xmppStream isConnected]) {
        [_xmppStream authenticateWithPassword:passWord error:&error];
        
        if (error) {
            _authFailure(XMPPErrorAuthenticateServerError);
        }
        return;
    }
    
    if (![_xmppStream connectWithTimeout:kConnectTimeOut error:&error]) {
        if (error) {
            _authFailure(XMPPErrorConnectServerError);
            return;
        }
    }
}

#pragma mark -
#pragma mark online/offline

- (void)goOnline
{
    // presence 的状态：available 上线   away 离开    do not disturb 忙碌    unavailable 下线
    NSLog(@"用户上线了");
//    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

- (void)goOffline
{
    NSLog(@"用户下线了");
    XMPPPresence *xmppPresence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:xmppPresence];
}

/** 断开连接 */
- (void)disconnect
{
    NSLog(@"断开了网络连接");
    // 通知服务器，用户下线
    [self goOffline];
    
    [self.xmppStream disconnect];
}

/** 清除用户的偏好 */
- (void)clearUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:LoginUserNameKey];
    [defaults removeObjectForKey:LoginPasswordKey];
    [defaults removeObjectForKey:LoginHostnameKey];
    [defaults removeObjectForKey:LoginloginStatus];
    
    // 刚存完偏好设置，必须同步一下
    [defaults synchronize];
}

/** 销毁调用 */
- (void)teardownXmppStream{
    // 移除代理
    [self.xmppStream removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    
    // 停止模块
    [_xmppReconnect deactivate];
    //    [_vCard deactivate];
    //    [_avatar deactivate];
//    [_xmppMessageArchiving deactivate];
    [self.xmppRoster deactivate];
    
    // 断开连接
    [_xmppStream disconnect];
    // 清空对象
    _xmppReconnect = nil;
    //    _vCard = nil;
    //    _vCardStorage = nil;
//    _xmppMessageArchiving = nil;
    //    _avatar = nil;
//    _xmppRosterCoreDataStorage = nil;
    _xmppRoster = nil;
    _xmppStream = nil;
}


// 销毁对象
- (void)dealloc{
    NSLog(@"xmppManager对象已被销毁");
    [self teardownXmppStream];
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket{
    
  NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
  NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    
    // 认证服务器
    if (_xmppOperation == XMPPLoginServerOperation) {
        NSError *error = nil;
        [_xmppStream authenticateWithPassword:[UserOperation shareduser].password error:&error];
        if (error) {
            if (_authFailure) {
                _authFailure(XMPPErrorAuthenticateServerError);
            }
        }
    }
    
    // 注册服务器
    if (_xmppOperation == XMPPRegisterServerOperation) {
        NSError *error = nil;
        [_xmppStream registerWithPassword:[UserOperation shareduser].password error:&error];
        if (error) {
            if (_authFailure) {
                _authFailure(XMPPErrorRegisterServerError);
            }
        }
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    
    // 断开连接时，用户下线
    [self goOffline];
    
    if (error)
    {
        if (_authFailure)
        {
            _authFailure(XMPPErrorDisConnectServerError);
        }
    }
}

/**
 *  注册成功时调用
 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    [_xmppRoster setNickname:sender.myJID.user forUser:sender.myJID];
    if (_authSuccess) {
        _authSuccess();
    }
}

/**
 *  注册失败时调用
 */
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    // 重复注册了用户名,注册名已存在!
    if (_authFailure) {
        _authFailure(XMPPErrorRegisterServerError);
    }

}

/**
 *  授权(登录)成功时调用
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    NSLog(@"完成认证，发送在线状态");
    // 通知服务器用户上线
    [self goOnline];
    [UserOperation shareduser].loginStatus = YES;
    [_xmppRoster fetchRoster];
    if (_authSuccess) {
        _authSuccess();
    }
}

/**
 *  授权失败时调用
 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"授权失败");
    // 断开与服务器的连接
    [self disconnect];
    // 清理用户偏好
    [self clearUserDefaults];

}



- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);

}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);

}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    if (_authFailure)
    {
        _authFailure(XMPPErrorConnectTimeOutError);
    }
}




@end
