//
//  ContactorViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "ContactorViewController.h"
#import "AddFriendViewController.h"
#import "XmppManager.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "ChatViewController.h"

@interface ContactorViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
/** 联系人列表 */
@property (nonatomic, weak) UITableView *contactorsTable;
/** 结果调度器 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSMutableArray* friendsList;
@end

@implementation ContactorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置子控件
    [self setupChildView];
    
    
    NSError *error = nil;
    // 查询数据， 如果有错误，打印错误
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"%@-fetchedResultsController", error);
    }
    
}

//-(NSMutableArray *)friendsList {
//    if (!_friendsList) {
//        _friendsList = @[].mutableCopy;
//    }
//    _friendsList = [NSMutableArray arrayWithArray:[[HYXMPPManager sharedManager] friendList:^(BOOL isUpdate) {
//        //
//        if (isUpdate) {
//            [self.tableView reloadData];
//        }
//    }]];
//    
//    return _friendsList;
//}



/** 设置子控件 */
- (void)setupChildView{
    self.navigationItem.title = @"联系人";
    UITableView *contactorsTable = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.contactorsTable = contactorsTable;
    [self.view addSubview:contactorsTable];
    self.contactorsTable.dataSource = self;
    self.contactorsTable.delegate = self;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"mail_add_contact_normal" highImage:nil target:self action:@selector(addFriendBtnClick)];
}

/** 懒加载结果调度器 */
- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
        // 指定查询的实体，也就是指定查哪一张表（这一张表格是xmppframework已经创建的）
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
        // 在线状态排序（排序关键字为表格中的key）
        NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
        // 显示的名称排序
        NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        // 添加排序
        request.sortDescriptors = @[sort1,sort2];
        // 添加谓词过滤器
        // subscription的种类 none表示对方还没有确认  to 我关注对方   from 对方关注我   both 互粉
        request.predicate = [NSPredicate predicateWithFormat:@"!(subscription CONTAINS 'none')"];
        // 添加上下文
        NSManagedObjectContext *ctx = [XmppManager sharedxmppManager].xmppRosterCoreDataStorage.mainThreadManagedObjectContext;
        // 实例化结果控制器
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
        // 设置他的代理
        _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)addFriendBtnClick{
    [self.navigationController pushViewController:[[AddFriendViewController alloc] init] animated:YES];

}

#pragma mark - ******************** NSFetchedResultsControllerDelegate
// 上下文改变触发，也就是刚加了好友，或删除好友时会触发
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"好友个数%ld--改变了上下文", self.fetchedResultsController.fetchedObjects.count);
    [self.contactorsTable reloadData];
}

#pragma mark - ******************** dataSource Methods

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return self.friendsList.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"联系人界面-%ld", self.fetchedResultsController.fetchedObjects.count);
    return self.fetchedResultsController.fetchedObjects.count;
//    return [self.friendsList[section] count];
}

static NSString * const ContactCellId = @"ContactCellId";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ContactCellId];
    }
    XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // 打印好友相关信息
    NSLog(@"%zd %@ %@ %@", user.section, user.sectionName, user.sectionNum, user.jidStr);
    // 设置cell显示信息
    NSString *str = [user.jidStr stringByAppendingFormat:@" | %@", [NSString relationshipWithFriend:user.subscription]];
    cell.textLabel.text = str ;
    cell.detailTextLabel.text = [self userStatusWithSection:user.section];
    return cell;
}

// 返回好友状态
- (NSString *)userStatusWithSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"在线";
            break;
        case 1:
            return @"离开";
            break;
        case 2:
            return @"离线";
            break;
        default:
            return @"未知";
            break;
    }
}

- (void)dealloc{
    NSLog(@"%s", __func__);
}

#pragma mark - ******************** 开启编辑模式删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        XMPPJID *userJid = user.jid;
        // 应该提示一下用户
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要删除?" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // 删除好友
            [[XmppManager sharedxmppManager].xmppRoster removeUser:userJid];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - ******************** tableView代理方法，跳转chatViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 跳转chatViewController
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    
    // 给chatViewController传输好友的jid
    XMPPUserCoreDataStorageObject *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    chatVC.friendJid = friend.jid;
    
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
