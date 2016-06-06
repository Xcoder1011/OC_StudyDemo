//
//  XmppManage.m
//  J1-IM
//
//  Created by wushangkun on 16/1/23.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "XmppManager.h"
#import "UserOperation.h"
#import "GroupChatManager.h"
#import "Message.h"
#import "Roster.h"

@interface XmppManager ()<XMPPStreamDelegate, XMPPRosterDelegate>
{
    // 自动连接对象
    XMPPReconnect *_xmppReconnect;
    // 电子名片存贮
//    XMPPvCardCoreDataStorage *_vCardStorage;
}
@end

@implementation XmppManager
#pragma mark - ******************** 单例方法
SingletonM(xmppManager);

#pragma mark - ******************** 初始化xmppStream(懒加载)
- (XMPPStream *)xmppStream{
    if(_xmppStream == nil){
        // 创建xmppStream   ----  xmpp基础服务类
        _xmppStream = [[XMPPStream alloc] init];
        // 允许socket后台运行
//        _xmppStream.enableBackgroundingOnSocket = YES;
        // 1.添加自动连接模块    ----  如果失去连接,自动重连
        _xmppReconnect=[[XMPPReconnect alloc]init];
        // 2.添加电子名片模块    ----  好友名片（昵称，签名，性别，年龄等信息）在core data中的操作类
//        _vCardStorage=[XMPPvCardCoreDataStorage sharedInstance];
        // 好友名片实体类模块
//        _vCard=[[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
        // 3.添加好友头像模块
//        _avatar=[[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vCard];
        // 4.添加花名册模块，好友列表（用户账号）在core data中的操作类
        _xmppRosterCoreDataStorage=[XMPPRosterCoreDataStorage sharedInstance];
        // 数据表 XMPPRoster 用来管理用户
        _xmppRoster=[[XMPPRoster alloc] initWithRosterStorage:_xmppRosterCoreDataStorage dispatchQueue:dispatch_get_global_queue(0, 0)];
        // 5.添加消息模块  ----  消息模块(如果支持多个用户，使用单例，所有的聊天记录会保存在一个数据库中)
        _xmppMessageArchivingCoreDataStorage=[XMPPMessageArchivingCoreDataStorage sharedInstance];
        // 存储消息模块
        _xmppMessageArchiving=[[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
        
        _roomCoreData = [XMPPRoomCoreDataStorage sharedInstance];
        
        // 取消接收自动订阅功能，需要确认才能够添加好友！
        _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
        
        // 激活模块（并不是所有的模块都需要添加，用到什么添加什么，添加完毕必须激活）
        [_xmppReconnect activate:_xmppStream];
//        [_vCard activate:_xmppStream];
//        [_avatar activate:_xmppStream];
        [_xmppRoster activate:_xmppStream];
        [_xmppMessageArchiving activate:_xmppStream];
        
        //添加代理   把xmpp流放到子线程
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_xmppStream addDelegate:[GroupChatManager sharedGroupManager] delegateQueue:dispatch_get_main_queue()];
        [_xmppStream addDelegate:[SessionManager sharedSessionManager] delegateQueue:dispatch_get_main_queue()];
        [_xmppStream addDelegate:[Roster sharedRoster] delegateQueue:dispatch_get_main_queue()];
        
    }
    return _xmppStream;
}

#pragma mark ******************** 调用连接的方法
- (void)connect:(void (^)(NSString *errorMessage))failed{
    // 先断开连接
//    [self.xmppStream disconnect];
    NSLog(@"开始连接服务器");
    //把block保存起来
    _failed = failed;
    //连接主机
    [self connectToHost];
}

- (void)connectToHost{
    NSLog(@"连接到服务器");
    // 需要指定myJID & hostName
    UserOperation *user = [UserOperation shareduser];
    NSString *hostName = user.hostUrl;
    NSString *username = user.username;
    self.userName = user.username;
    
    // 设置xmppStream的连接信息(服务器地址，myJID，端口号)
    self.xmppStream.hostName = hostName;
    self.jidName = [username stringByAppendingFormat:@"@%@", hostName];
    self.xmppStream.myJID = [XMPPJID jidWithString:_jidName];
    NSLog(@" self.jid in connectToHost == %@",self.jidName);
    // 可以不设定，会使用默认端口号
    self.xmppStream.hostPort = ServerPort;
    
    //连接到服务器，如果有错误讲打印错误信息
    NSError *error = nil;
    if(![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]){
        NSLog(@"%@",error);
    }
}

- (NSString *)jidName{
    return _jidName;
}

-(NSString *)userName{
    return _userName;
}

/** 断开连接 */
- (void)disconnect
{
    NSLog(@"断开了网络连接");
    // 通知服务器，用户下线
    [self goOffline];
    
    [self.xmppStream disconnect];
}

#pragma mark - ******************** 用户的上线和下线
// presence 的状态：available 上线   away 离开    do not disturb 忙碌    unavailable 下线

// 上线 available
- (void)goOnline {
    NSLog(@"用户上线了");
    XMPPPresence *p = [XMPPPresence presenceWithType:@"available"];
    
    [self.xmppStream sendElement:p];
}

// 下线 unavailable
- (void)goOffline {
    NSLog(@"用户下线了");
    XMPPPresence *p = [XMPPPresence presenceWithType:@"unavailable"];
    
    [self.xmppStream sendElement:p];
}

// 登出
- (void)logout {
    NSLog(@"当前用户已被注销");
    // 所有用户信息是保存在用户偏好，注销应该删除用户偏好记录
    [self clearUserDefaults];
    
    // 下线，并且断开连接
    [self disconnect];
}

#pragma mark - ******************** 清除的方法
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
    [_xmppMessageArchiving deactivate];
    [self.xmppRoster deactivate];
    
    // 断开连接
    [_xmppStream disconnect];
    // 清空对象
    _xmppReconnect = nil;
//    _vCard = nil;
//    _vCardStorage = nil;
    _xmppMessageArchiving = nil;
//    _avatar = nil;
    _xmppRosterCoreDataStorage = nil;
    _xmppRoster = nil;
    _xmppStream = nil;
}

// 销毁对象
- (void)dealloc{
    NSLog(@"xmppManager对象已被销毁");
    [self teardownXmppStream];
}

#pragma mark - ******************** xmppStream代理方法
/** 注册成功时调用 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
    // 登出，清除本地数据
    [self logout];
    
    // 弹框提醒用户注册成功
    dispatch_async(dispatch_get_main_queue(), ^{
        self.failed(@"注册成功！～请登录");
    });
}

/** 注册失败时调用 */
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"注册失败了");
    // 弹框提醒用户注册失败
    dispatch_async(dispatch_get_main_queue(), ^{
        self.failed(@"该用户名已被占用！～请重新注册");
    });
}

/** 连接成功时调用 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接成功");
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:LoginPasswordKey];
//    NSLog(@"%@====password", password);
    
    if (self.isRegisterOperation) {
        // 将用户密码发送给服务器，进行用户注册
        [self.xmppStream registerWithPassword:password error:NULL];
        // 将注册标记复位
        self.isRegisterOperation = NO;
    } else {
        // 将用户密码发送给服务器，进行用户登录
        [self.xmppStream authenticateWithPassword:password error:NULL];
    }
}

/** 断开连接时调用 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"断开连接");
    // 断开连接时，用户下线
    [self goOffline];
    // 在主线程更新UI(用户自己断开的不算)
    if (self.failed && error) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"无法连接到服务器");});
    }
}

/** 授权成功时调用  （就是密码正确）*/
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"授权成功");
    
    // 通知服务器用户上线
    [self goOnline];
    // 通过授权意味着用户已登录
    [UserOperation shareduser].loginStatus = YES;
    
    // 在主线程利用通知发送广播
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@(YES)];
    });
}

/** 授权失败时调用 （就是密码错误）*/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    NSLog(@"授权失败");
    // 断开与服务器的连接
    [self disconnect];
    // 清理用户偏好
    [self clearUserDefaults];
    
    // 在主线程更新UI
    if (self.failed) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"用户名或者密码错误！");});
    }
    
    // 在主线程利用通知发送广播
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@(NO)];
    });
}

#pragma mark - ******************** XMPP花名册代理
// 接收到好友请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"%s", __func__);
    NSString *msg = [NSString stringWithFormat:@"%@请求添加为好友，请确认", presence.from];
    
    // 弹框提醒用户
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 接受好友申请
        NSLog(@"接受了好友申请");
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
        
    }]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

#pragma mark - ******************** DIY
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"%s", __func__);
}

-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"%s", __func__);
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
//    NSLog(@"%s", __func__);
    
}

// 通过好友姓名添加好友
- (void)addFriendWithFriendName:(NSString *)friendName{
    // 检索输入框，看是否有@符号
    NSRange range = [friendName rangeOfString:@"@"];
    // 如果没有找到，那么location为NSNotFound
    if (range.location == NSNotFound) {
        friendName = [friendName stringByAppendingFormat:@"@%@", _xmppStream.myJID.domain];
        NSLog(@"%@--addFriend", friendName);
    }
    // 根据好友名字创建一个JID对象 
    XMPPJID *friendJid = [XMPPJID jidWithString:friendName];
    // 判断好友是否已存在花名册中
    BOOL contains = [self.xmppRosterCoreDataStorage userExistsWithJID:friendJid xmppStream:_xmppStream];
    // 如果已存在，弹框提醒用户
    if (contains) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"已经是好友，无需添加" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    // 如果不存在，将用户添加到当前用户的花名册
    [_xmppRoster subscribePresenceToUser:friendJid];
}

#pragma mark - ******************** 收发消息的方法
/** 发送信息(单聊) */
- (void)sendMessage:(NSString *)message toUser:(XMPPJID *)userJID{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:userJID];
    
    [msg addBody:message];
    
    [self.xmppStream sendElement:msg];
}


@end
