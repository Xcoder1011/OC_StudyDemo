//
//  ChatViewController.m
//  J1-IM
//
//  Created by liang on 16/1/28.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPJID.h"
#import "XMPPMessage.h"
#import "MyChatCell.h"
#import "FriendChatCell.h"
@interface ChatViewController ()<UITableViewDataSource, UIScrollViewDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputVIewBottomConstraint;
// 结果调度器
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.fetchedResultsController performFetch:NULL];
    // 设置子控件
    [self setupChildView];
}

- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController != nil) {
        return  _fetchedResultsController;
    }
    // 这个coredata文件在XEP-0136里
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    // 根据时间顺序进行排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    // 这里只需要取出聊天对象的消息    bare举例：spark@127.0.0.1
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.friendJid.bare];
    // 获取上下文
    NSManagedObjectContext *ctx = [XmppManager sharedxmppManager].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    // 实例化结果调度器
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

static NSString * const MyChatCellId = @"myChatCell";
static NSString * const FriendChatCellId = @"friendChatCell";
// 设置子控件
- (void)setupChildView{
    self.navigationItem.title = self.friendJid.user;
    self.contentTV.delegate = self;
    // 设置表格的背景图片
    self.chatTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg"]];
    // 通知来监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // 注册两种cell
    [self.chatTableView registerNib:[UINib nibWithNibName:NSStringFromClass([MyChatCell class]) bundle:nil] forCellReuseIdentifier:MyChatCellId];
    [self.chatTableView registerNib:[UINib nibWithNibName:NSStringFromClass([FriendChatCell class]) bundle:nil] forCellReuseIdentifier:FriendChatCellId];
    self.chatTableView.rowHeight = 100;
    [self scrollToBottom];
    
    
}

// 点击了发送Btn
- (IBAction)sendBtnClick {
    NSLog(@"发送的文字为：%@", self.contentTV.text);
    [[XmppManager sharedxmppManager] sendMessage:self.contentTV.text toUser:self.friendJid];
    self.contentTV.text = nil;
}

// 点击了图片Btn
- (IBAction)imageBtnClick {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 自定义方法来发送二进制文件
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [message addBody:name];
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    //包含子节点
    [message addChild:attachment];
    // 发送消息
//    [[XmppManager sharedxmppManager].xmppStream sendElement:message];
}

#pragma mark - ******************** imgPickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    [self sendMessageWithData:data bodyName:@"image"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ******************** 监听键盘弹出的方法
- (void)keyboardChanged:(NSNotification *)noti{
    // 获取键盘的变化
    CGRect keyboardRect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 设置约束
    self.inputVIewBottomConstraint.constant = DeviceHeight - keyboardRect.origin.y;
    // 获取键盘弹出的时间
    NSTimeInterval time = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:time animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - ******************** 结果调度器的代理方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.chatTableView reloadData];
    // 滚动到最底部
    [self scrollToBottom];
}

#pragma mark - ******************** tableView数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSLog(@"消息条数：%ld", self.fetchedResultsController.fetchedObjects.count);
    return self.fetchedResultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellWithTableView:tableView andIndexPath:indexPath];
}

- (UITableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    // 取出当前行消息
    XMPPMessageArchiving_Message_CoreDataObject *currentMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // 判断该消息是发出的消息还是收到的消息
    if ([currentMessage.outgoing intValue] == 1) {
        MyChatCell *cell = [tableView dequeueReusableCellWithIdentifier:MyChatCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.messageLabel.text = currentMessage.body;
        return cell;
    }else{
        FriendChatCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendChatCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.messageLabel.text = currentMessage.body;
        return cell;
    }
}


#pragma mark - ******************** scrollView代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

// 滚动到表格的末尾，显示最新的聊天内容
- (void)scrollToBottom {
    
    // 1. indexPath，应该是最末一行的indexPath
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    // 数组里面没东西还滚，不是找崩么
    if (count > 3) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
        
        // 2. 将要滚动到的位置
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - ******************** textView代理方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    // 判断按下的是不是回车键。
    if ([text isEqualToString:@"\n"]) {
        
        [self sendBtnClick];
        
        return NO;
    }
    return YES;
}

@end
