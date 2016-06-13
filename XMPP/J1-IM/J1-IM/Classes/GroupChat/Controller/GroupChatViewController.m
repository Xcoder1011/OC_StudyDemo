//
//  GroupChatViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/1/28.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "GroupChatViewController.h"
#import "ChatTableViewCell.h"
#import "CreateGroupViewController.h"
#import "ChatMore_FaceView.h"
#define MaxOpenHeight 100



// ************************************ ChatToolBar  ************************************ /

@class ChatToolBar;
@protocol ChatToolBarDelegate <NSObject>

-(void)chatToolBar:(ChatToolBar *)toolBar showHeight:(CGFloat)height;
-(void)chatToolBar:(ChatToolBar *)toolBar sendContent:(NSString *)content;
@end


@interface ChatToolBar : UIView
<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UITextView *contentTextView;
    UIControl *touchResignFirstResponderController;
    
    CGFloat curShowHeight;
    CGFloat inputHeight;
    CGFloat invHeight;
    
    UIButton *preOperBtn;
    BOOL isUpMoreView;

}

@property (nonatomic ,weak) id<ChatToolBarDelegate>delegate;
@property (nonatomic, strong) UIView * moreView;

@property (nonatomic, strong) ChatMore_FaceView * moreFaceView;



@property (nonatomic, copy) NSString * content;
@property (nonatomic,copy) void(^selectImagesCall)(NSArray *);

/**
 *  添加内容
 *
 *  @param content 内容
 */
- (void)appContent:(NSString *)content;

/**
 *  删除内容最后一个文字
 */
- (void)removeLastOneContent;

@end

@implementation ChatToolBar
-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
    //    self.backgroundColor = UIColorFromAlphaRGB(235, 236, 238, 1);
        self.backgroundColor = [UIColor greenColor];

        [self layoutView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UIKeyboardWillChangeFrameNotification object:nil];

    }
    return self;
}

- (void)appContent:(NSString *)content
{
    
    contentTextView.text = [contentTextView.text stringByAppendingString:content];
    [contentTextView scrollRangeToVisible:NSMakeRange(contentTextView.text.length, 0)];
    [self calueText:contentTextView];
}

/**
 *  删除内容最后一个
 */
- (void)removeLastOneContent
{
    if (contentTextView.text.length == 0) {
        return;
    }
    unichar c;
    int length = 1;
    [contentTextView.text getCharacters:&c range:NSMakeRange(contentTextView.text.length - 1, 1)];
    
    // emoji 表情占2个字符
    if (c >= 56000) {
        length = 2;
    }
    
    contentTextView.text = [contentTextView.text stringByReplacingCharactersInRange:NSMakeRange(contentTextView.text.length - length, length) withString:@""];
    [contentTextView scrollRangeToVisible:NSMakeRange(contentTextView.text.length, 0)];
    [self calueText:contentTextView];
}

-(UIView *)moreView{
    if (!_moreView) {
        _moreView = [[UIView alloc]initWithFrame:CGRectMake(0, DeviceHeight, self.frame.size.width, 200)];
        _moreView.backgroundColor = UIColorFromAlphaRGB(235, 236, 238, 1);
      //  _moreView.backgroundColor = [UIColor redColor];

    }
    return _moreView;
}

-(void)setContent:(NSString *)content{
    contentTextView.text = content;
    
    [self calueText:contentTextView];

}

-(NSString *)content{
    return contentTextView.text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)calueText:(UITextView *)textView
{
    CGSize size = CGSizeZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    CGRect frame = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : textView.font} context:nil];
    size = frame.size;
#else
    size = [textView.text sizeWithFont:textView.font constrainedToSize:CGSizeMake(textView.frame.size.width, 999)];
#endif
    
    
    CGRect inputBoudns = [contentTextView frame];
    CGRect boudns = [self frame];
    
    inputBoudns.size.height = size.height > inputHeight ? size.height > MaxOpenHeight ? MaxOpenHeight : size.height : inputHeight;
    
    boudns.size.height = inputBoudns.size.height + invHeight;
    self.frame = boudns;
    contentTextView.frame = inputBoudns;
    
    
    [self willShowButtomHeight:curShowHeight];
}

/**
 *  设置将要弹起的高度
 *
 *  @param height 高度
 */
- (void)willShowButtomHeight:(CGFloat)height
{
    
    CGRect frame = self.frame;  //frame = (origin = (x = 0, y = 524), size = (width = 320, height = 44))
//    CGFloat inv = 0;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        inv = 64;
//    }
    //frame.origin.y = self.window.frame.size.height - height - frame.size.height - inv ; //new add
    frame.origin.y = self.window.frame.size.height - height - frame.size.height ; //new add

    self.frame = frame; //frame = (origin = (x = 0, y = 460), size = (width = 320, height = 44))
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:showHeight:)] && curShowHeight != height) {
        [_delegate chatToolBar:self showHeight:height];
    }
    curShowHeight = height;
}


/**
 *  初始化界面布局
 */
-(void)layoutView
{
    UIButton *recordBtn = [self quickCreateButton:[UIImage imageNamed:@"chat_bottom_voice_nor@3x.png"]
                                       pressImage:[UIImage imageNamed:@"chat_bottom_voice_press@3x.png"]
                                      selectImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor@3x.png"]
                                           Method:@selector(btnClick:)
                                            Frame:CGRectMake(5, 5, self.frame.size.height - 10, self.frame.size.height - 10) withTag:10];
    [self addSubview:recordBtn];
    
    //contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(recordBtn.frame.origin.x + recordBtn.frame.size.width + 5, (self.frame.size.height - (self.frame.size.height - 8)) / 2, self.frame.size.width - self.frame.size.height * 3 + 5, self.frame.size.height - 8)];

    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(recordBtn.right + 5, (self.height - (self.height - 8)) / 2, self.frame.size.width - self.frame.size.height * 3 + 5, self.height - 8)];
    contentTextView.font = [UIFont systemFontOfSize:15];
    contentTextView.layer.cornerRadius = 5.0f;
    contentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    contentTextView.layer.borderWidth = 1 / [UIScreen mainScreen].scale / 2.0f;
    contentTextView.returnKeyType = UIReturnKeySend;
    contentTextView.delegate = self;
    contentTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight |  UIViewAutoresizingFlexibleWidth;
    [self addSubview:contentTextView];
    
    inputHeight = contentTextView.height;  //0
    invHeight = self.height - contentTextView.height; //36
    
    UIButton *faceBtn = [self quickCreateButton:[UIImage imageNamed:@"chat_bottom_smile_nor@3x.png"]
                                     pressImage:[UIImage imageNamed:@"chat_bottom_smile_press@3x.png"]
                                    selectImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor@3x.png"]
                                         Method:@selector(btnClick:)
                                          Frame:CGRectMake(self.width - self.height * 2 + 12.5, 5, self.frame.size.height - 10, self.frame.size.height - 10) withTag:11];
    [self addSubview:faceBtn];
    
    UIButton *moreBtn = [self quickCreateButton:[UIImage imageNamed:@"chat_bottom_up_nor@3x.png"]
                                     pressImage:[UIImage imageNamed:@"chat_bottom_up_press@3x.png"]
                                    selectImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor@3x.png"]
                                         Method:@selector(btnClick:)
                                          Frame:CGRectMake(self.width - self.height + 5, 5, self.frame.size.height - 10, self.frame.size.height - 10) withTag:12];
    [self addSubview:moreBtn];
    
   // HYWeakSelf;
    
    _moreFaceView = [[ChatMore_FaceView alloc]initWithFrame:self.moreView.bounds];
    [self.moreView addSubview:self.moreFaceView];

}

-(void)btnClick:(UIButton *)btn
{
    if (preOperBtn == btn) {
        return;
    }
    
    self.moreFaceView.hidden = NO;
    
    switch (btn.tag) {
        case 10: //语音
            
            break;
        case 11: //表情
            self.moreFaceView.hidden = NO;
            break;
        case 12: //operation
            break;
            
        default:
            break;
    }
    
    if (!isUpMoreView) {
        [contentTextView resignFirstResponder];
        CGFloat height = 0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        [self addTouchResignFirstResponder];
        height = self.moreView.frame.size.height; //200
        CGRect frame = self.moreView.frame;
        //frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height - 64;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height; //new add

#else
        height = self.moreView.frame.size.height;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
#endif
        [UIView animateWithDuration:0.25 animations:^{
            self.moreView.frame = frame;
            [self willShowButtomHeight:height];
        }];
        
         preOperBtn = btn;
    }

   
}


/**
 *  快速创建默认的 Button
 *
 *  @param image       默认Image
 *  @param pressImage  按下Image
 *  @param selectImage 选中Image
 *  @param method      触发方法
 *  @param frame       frame
 *
 *  @return <#return value description#>
 */
-(UIButton *)quickCreateButton:(UIImage *)image pressImage:(UIImage *)pressImage selectImage:(UIImage *)selectImage Method:(SEL)method Frame:(CGRect)frame withTag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:0];
    [btn setImage:pressImage forState:UIControlStateHighlighted];
    [btn setImage:selectImage forState:UIControlStateSelected];
    [btn addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    btn.frame = frame;
    btn.tag = tag;
    return btn;
}


/**
 *  键盘通知接受方法
 *
 *  @param noti <#noti description#>
 */
- (void)noti:(NSNotification *)noti
{
    NSDictionary * userInfo = noti.userInfo;
    
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
        //beginFrame = (origin = (x = 0, y = 568), size = (width = 320, height = 253))
        //endFrame = (origin = (x = 0, y = 315), size = (width = 320, height = 253))
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
    
}

/**
 *  通过键盘的frame 计算出要弹起的高度
 *
 *  @param beginFrame 起始Frame
 *  @param toFrame    结束Frame
 */
- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    CGFloat height = 0;
    if (toFrame.origin.y == [UIScreen mainScreen].bounds.size.height)
    {
        [self deleteTouchResignFirstResponder];
    } else {
        [self cancelMoreView];
        [self addTouchResignFirstResponder];
        height = toFrame.size.height;
    }
    
    
    [self willShowButtomHeight:height];
}

/**
 *  添加点击屏幕取消键盘control
 */
- (void)addTouchResignFirstResponder
{
    if (!touchResignFirstResponderController) {
        touchResignFirstResponderController = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [touchResignFirstResponderController addTarget:self action:@selector(touchResignFirstResponder:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.superview insertSubview:touchResignFirstResponderController belowSubview:self];
    }
}

/**
 *  点击屏幕取消键盘事件
 *
 *  @param control
 */
- (void)touchResignFirstResponder:(UIControl *)control
{
    NSLog(@"touch");
    [self cancelMoreView];
    [contentTextView resignFirstResponder];
    [self deleteTouchResignFirstResponder];
}

/**
 *  取消显示MoreView
 */
- (void)cancelMoreView
{
    
    CGRect frame = self.moreView.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.moreView.frame = frame;
        [self willShowButtomHeight:0];
    } completion:^(BOOL finished) {
    }];
    preOperBtn = nil;
    isUpMoreView = NO;
}

/**
 *  删除点击屏幕取消键盘control
 */
- (void)deleteTouchResignFirstResponder
{
    [touchResignFirstResponderController removeFromSuperview];
    touchResignFirstResponderController = nil;
}


// MARK: - TextView Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self calueText:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:sendContent:)]) {
            [_delegate chatToolBar:self sendContent:textView.text];
            textView.text = @"";
            [self calueText:textView];
        }
        return NO;
    }
    return YES;
}


@end



// ************************************ GroupChatViewController  ************************************ /

@interface GroupChatViewController () <UITableViewDelegate,UITableViewDataSource,ChatToolBarDelegate>
{
    CGRect originFrame;
    
    BOOL isLoadMessageing;
    BOOL isCanLoadMessage;
    
    NSDate * lastSendDate;
    NSInteger sumMessageCount;
    
    //    Message * prePlayMessage; // 上一个播放语音的message
    //
    //    void (^_eventResponer) (Message * message, BubblePressType type);
    //    void (^_menuItemClick) (ChatTableViewCell * cell ,MenuItemType type);
    
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) ChatToolBar * toolBar;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, strong) UIMenuController * menuController;

@end

@implementation GroupChatViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTalkNotification:) name:RefreshTalksNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp]; //配置
    
    [self loadTalkList]; //加载数据
  
}

-(void)loadTalkList{
    if (self.member) { //单聊
        [[Roster sharedRoster]clearUnreadMessageNumForJid:self.member.jid];
        self.dataArr = [[SessionManager sharedSessionManager]talksWithJid:self.member.jid];
    }else{ //群聊
        
        self.dataArr = [[SessionManager sharedSessionManager]talksWithJid:self.chatRoom.chatRoomJid];
    }
    [self.tableView reloadData];
//    if (self.dataArr.count>0){
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }

}

- (id)initWithUserName:(NSString *)_userName
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
//        username = _userName;
//        
//        _session = [MQChatManager sessionForUserName:username Default:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTalkNotification:) name:RefreshTalksNotification object:nil];
        
    }
    return self;
}



-(void)setUp{
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTalkNotification:) name:RefreshTalksNotification object:nil];

    [self setNavRightItemWith:@"邀请成员" andImage:nil];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@",self.chatRoom.name];
 //   UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"face2add_bg_morning.png"]];
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beijingtupian2.jpeg"]];

    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backgroundImageView];
    //self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.toolBar];
    
    originFrame = self.tableView.frame;
    [self.view addSubview:self.toolBar.moreView];
    
    self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    isCanLoadMessage = YES;

}

-(void)rightItemClick:(id)sender{
    
    CreateGroupViewController  * create = [[CreateGroupViewController alloc]init];
    create.isInviteMember = YES  ;
    [self.navigationController pushViewController:create animated:YES];

}

- (ChatToolBar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[ChatToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        _toolBar.delegate = self;
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _toolBar;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
       // CGRect frame = _tableView.frame;
//        frame.size.height -= self.toolBar.frame.size.height; //height = self.view.frame.size.height-64 - 44
//        _tableView.frame = frame;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.backgroundColor = [UIColor clearColor];
        UIEdgeInsets edge = _tableView.contentInset;
        edge.top += 10;
        //edge.bottom += 20;
        _tableView.contentInset = edge;
    }
    
    return _tableView;
}

// MARK: - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatTableViewCell heightForMessageModel:[self.dataArr objectAtIndex:indexPath.row]] - 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id message = [self.dataArr objectAtIndex:indexPath.row];
    
    ChatTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[ChatTableViewCell cellIdentifierForMessageModel:message]];
    
    if (!cell) {
        cell = [[ChatTableViewCell alloc] initWithMessageModel:message];
        
//        cell.menuItemClick = _menuItemClick;
//        
//        cell.bubbleView.eventResponer = _eventResponer;
    }
    
    cell.message = message;
    return cell;
}

// MARK: - ChatToolBar Delegate
-(void)chatToolBar:(ChatToolBar *)toolBar showHeight:(CGFloat)height
{
    
    UITableViewCell * cell = [[self.tableView visibleCells] lastObject];
    
    //CGRect frame = self.view.bounds;
    CGRect frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    frame.size.height -= height + toolBar.frame.size.height;
   
    
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.frame = frame;
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } completion:^(BOOL finished) {
        
    }];
} 

-(void)chatToolBar:(ChatToolBar *)toolBar sendContent:(NSString *)content
{
    if ([content isEqualToString:@""]) {
        return;
    }
    [self sendContent:content];
    NSLog(@"发送消息:%@",content);

}


// MARK: - 各种类型发送信息
- (void)sendContent:(NSString *)content
{
    if (self.member) { //单聊
        [[SessionManager sharedSessionManager]sendMessage:content toJid:self.member.jid toName:self.member.name];
        
    }else{ //群聊
        [[SessionManager sharedSessionManager]sendMessage:content inChatRoom:self.chatRoom.chatRoomJid];
    }

}


#pragma mark - Notification
-(void)refreshTalkNotification:(NSNotification*)notification{
    //    int unread_total=[[DRRRRoster sharedRoster] memberByJid:self.member.jid].unread_total;
    //    NSLog(@"unread_total:%d",unread_total);
    [self loadTalkList];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
