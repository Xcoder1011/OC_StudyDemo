//
//  MessageViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCell.h"
#import "ChatViewController.h"
@interface MessageViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) UITableView *messageTable;
// 结果调度器(联系人)
@property (nonatomic, strong) NSFetchedResultsController *contactorsFetchedResultsController;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildView];
    [self.contactorsFetchedResultsController performFetch:NULL];
}

- (void)setupChildView{
    self.navigationItem.title = @"消息";
    UITableView *messageTable = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:messageTable];
    self.messageTable = messageTable;
    self.messageTable.dataSource = self;
    self.messageTable.delegate = self;
    [self.messageTable registerNib:[UINib nibWithNibName:NSStringFromClass([MessageCell class]) bundle:nil] forCellReuseIdentifier:MessageCellId];
    self.messageTable.rowHeight = 65;
}

/** 懒加载结果调度器 */
- (NSFetchedResultsController *)contactorsFetchedResultsController{
    if (_contactorsFetchedResultsController != nil) {
        return _contactorsFetchedResultsController;
    }
    // 指定查询的实体，也就是指定查哪一张表（这一张表格是xmppframework已经创建的）
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    // 在线状态排序（排序关键字为表格中的key）
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
    // 添加排序
    request.sortDescriptors = @[sort1];
    // 添加谓词过滤器
    // subscription的种类 none表示对方还没有确认  to 我关注对方   from 对方关注我   both 互粉
    request.predicate = [NSPredicate predicateWithFormat:@"!(subscription CONTAINS 'none')"];
    // 添加上下文
//    NSManagedObjectContext *ctx = [XmppManager sharedxmppManager].xmppRosterCoreDataStorage.mainThreadManagedObjectContext;
//    // 实例化结果控制器
//    _contactorsFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    // 设置他的代理
    _contactorsFetchedResultsController.delegate = self;
    
    return _contactorsFetchedResultsController;
}

/** 懒加载结果调度器 */
//- (NSFetchedResultsController *)contactorsFetchedResultsController{
//    if (_contactorsFetchedResultsController != nil) {
//        return _contactorsFetchedResultsController;
//    }
//    // 指定查询的实体，也就是指定查哪一张表（这一张表格是xmppframework已经创建的）
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
//    // 在线状态排序（排序关键字为表格中的key）
//    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:YES];
//    // 添加排序
//    request.sortDescriptors = @[sort1];
//    NSString *userJIDName = [XmppManager sharedxmppManager].jidName;
//    // 添加谓词过滤器
//    request.predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", userJIDName];
//    // 添加上下文
//    NSManagedObjectContext *ctx = [XmppManager sharedxmppManager].xmppRosterCoreDataStorage.mainThreadManagedObjectContext;
//    // 实例化结果控制器
//    _contactorsFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
//    // 设置他的代理
//    _contactorsFetchedResultsController.delegate = self;
//    
//    return _contactorsFetchedResultsController;
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"消息的上下文发生了变化");
    [self.messageTable reloadData];
}

#pragma mark - ******************** tableViewDateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSLog(@"%lu", self.contactorsFetchedResultsController.fetchedObjects.count);
    return self.contactorsFetchedResultsController.fetchedObjects.count;
}

static NSString * const MessageCellId = @"messageCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellId];
    XMPPUserCoreDataStorageObject *user = [self.contactorsFetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = user.jid.user;
    
    
    return cell;
}

//static NSString * const MessageCellId = @"messageCell";
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellId];
//    XMPPMessageArchiving_Contact_CoreDataObject *contact = [self.contactorsFetchedResultsController objectAtIndexPath:indexPath];
//    cell.nameLabel.text = contact.bareJidStr;
//    cell.contentTextLabel.text = contact.mostRecentMessageBody;
//    
//    return cell;
//}

#pragma mark - ******************** tableView代理方法，跳转chatViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 跳转chatViewController
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    
    // 给chatViewController传输好友的jid
    XMPPUserCoreDataStorageObject *friend = [self.contactorsFetchedResultsController objectAtIndexPath:indexPath];
    chatVC.friendJid = friend.jid;
    
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
