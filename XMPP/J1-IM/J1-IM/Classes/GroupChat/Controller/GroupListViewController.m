//
//  GroupListViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/1/26.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "GroupListViewController.h"
#import "HYTabBar.h"
#import "GroupChatManager.h"
#import "GroupChatViewController.h"
#import "CreateGroupViewController.h"

#define ChatRoomListCellIdentity @"chatroom-cell"


@interface GroupListViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSString * _password;
}


@property (nonatomic ,assign) ChatRoom *selectedChatRoom;

@property (nonatomic ,strong) UITableView *tbView;

@property (nonatomic ,strong) NSString *password;

@end

@implementation GroupListViewController
-(instancetype)init
{
    self = [super init];
    if (self) {
        //刷新房间列表时发出的通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshChatRoomListNotification) name:ChatRoomRefreshRoomsNotification object:nil];
    }
    return self;
}

//-(void)viewWillAppear:(BOOL)animated{
//    
//    self.tabBarController.hidesBottomBarWhenPushed = YES;
//    
//    
//}
//-(void)viewWillDisappear:(BOOL)animated
//{
//    self.tabBarController.hidesBottomBarWhenPushed = NO;
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"群组";
    
    [self initTableView];
    // 加载数据
    [self loadData];
}


-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initTableView
{
    [self setNavRightItemWith:@"创建房间" andImage:nil];
    
    UITableView *tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DeviceWidth, self.view.size.height) style:UITableViewStyleGrouped];
    [tabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:ChatRoomListCellIdentity];
    tabelView.delegate = self;
    tabelView.dataSource = self;
    self.tbView = tabelView;
    tabelView.tableHeaderView = [UIView new];
    [self.view addSubview:tabelView];
}

-(void)rightItemClick:(id)sender{
    
    
    CreateGroupViewController  * create = [[CreateGroupViewController alloc]init];
    create.isInviteMember = NO;
    [self.navigationController pushViewController:create animated:YES];
}

-(void)loadData{
        //查询服务列表
   // [[GroupChatManager sharedGroupManager]queryChatRoomsInService:[UserOperation shareduser].hostUrl];
    
   // [[XmppRoomManager sharedXmppRoomManager]queryRooms];
    
    [[GroupChatManager sharedGroupManager]queryRoomsWithMCU];

    
}




//刷新房间列表时发出的通知
-(void)refreshChatRoomListNotification
{
    NSDictionary *chatRoomDict = [GroupChatManager sharedGroupManager].chatRoomDict;
    NSLog(@"*********** chatRoomDict:\n%@",chatRoomDict);
    
   // NSLog(@"*********** chatRoomDict:\n%d",[XmppRoomManager sharedXmppRoomManager].roomList.count);

    
    [self.tbView reloadData];
}
-(NSString *)password{
    return _password;
}


#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [GroupChatManager sharedGroupManager].chatRoomDict.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatRoomListCellIdentity];
    NSDictionary *chatRoomsDict = [GroupChatManager sharedGroupManager].chatRoomDict;
    NSString *chatRoomJid = chatRoomsDict.allKeys[indexPath.row];
    ChatRoom *room = chatRoomsDict[chatRoomJid];
    cell.textLabel.text = room.name;
    if (room.chatRoomInfo) {
        cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
        cell.detailTextLabel.text = room.chatRoomInfo.roomDescription;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *chatRoomsDict = [GroupChatManager sharedGroupManager].chatRoomDict;
    NSString *chatRoomJid = chatRoomsDict.allKeys[indexPath.row];
    ChatRoom *room = chatRoomsDict[chatRoomJid];
    NSLog(@"room.chatRoomInfo = %@",room.chatRoomInfo);
    
    /*
    chatRoomsDict:
     {
        "room1@conference.127.0.0.1" = "<ChatRoom: 0x7d0c64b0>";
        "room2@conference.127.0.0.1" = "<ChatRoom: 0x7d191e20>";
    }*/
    if (room.chatRoomInfo) {
        self.selectedChatRoom = room;
        if (room.chatRoomInfo.needPassword) { //需要密码
            
            @HYWeakObj(self)
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"进入房间需要提供密码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //
            }];
            UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([alert.textFields objectAtIndex:0].text.length == 0) {
                    alert.message  = @"请输入正确的密码";
                }else{
                    [Weakself gotoChatRoomWithJid:Weakself.selectedChatRoom.chatRoomJid andPassword:[alert.textFields objectAtIndex:0].text];
                }
               
            }];
            [alert addAction:cancel];
            [alert addAction:sure];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                //
                textField.textColor = [UIColor redColor];
                Weakself.password = textField.text;
            }];
            
            [self presentViewController:alert animated:YES completion:^{
                //
            }];
            
            return;
        }else{
            //进入房间
            [self gotoChatRoomWithJid:self.selectedChatRoom.chatRoomJid andPassword:nil];
        
        }
    }else
    {
        [[GroupChatManager sharedGroupManager]queryChatRoomInfo:chatRoomJid];
    }
}


//进入房间
-(void)gotoChatRoomWithJid:(NSString *)roomJid andPassword:(NSString *)password{
    NSLog(@"进入房间roomJid:%@",roomJid);
    
    [[GroupChatManager sharedGroupManager]joinInChatRoom:self.selectedChatRoom.chatRoomJid withPassword:password];
    
    
    GroupChatViewController* groupChatCtrl = [[GroupChatViewController alloc]init];
    groupChatCtrl.chatRoom = self.selectedChatRoom;
    [self.navigationController pushViewController:groupChatCtrl animated:YES];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
