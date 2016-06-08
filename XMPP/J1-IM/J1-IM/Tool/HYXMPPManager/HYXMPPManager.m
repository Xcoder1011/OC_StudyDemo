//
//  HYXMPPManager.m
//  J1-IM
//
//  Created by wushangkun on 16/6/7.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "HYXMPPManager.h"

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
    _xmppReconnet = [[XMPPReconnect alloc]init];
    _xmppReconnet.autoReconnect = YES;
    
    //花名册
    


    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppReconnet addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
    [_xmppReconnet activate:_xmppStream];
 
}

#pragma mark --  登录

- (void)loginWithUserName:(NSString *)userName
                 passWord:(NSString *)passWord
                  success:(Success)success
                  failure:(Failure)failure{
    
//    self.userName = userName;
//    self.jidName = []
    if (!userName || !passWord ) {
        return ;
    }
    NSString *xmppJIDString = [NSString stringWithFormat:@"%@@%@",userName,kServerName];
    [self.xmppStream setMyJID:[XMPPJID jidWithString:xmppJIDString resource:@"iOS"]];
    
    NSError *error = nil;
    
    if ([_xmppStream isConnected]) {
        [_xmppStream authenticateWithPassword:passWord error:&error];
        
        if (error) {
            failure(error);
        }
        return;
    }
    
    if (![_xmppStream connectWithTimeout:kConnectTimeOut error:&error]) {
        if (error) {
            failure(error);
        }
        return;
    }
}


@end
