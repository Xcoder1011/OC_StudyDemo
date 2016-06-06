//
//  CreateGroupViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/2/3.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "CreateGroupViewController.h"

#import "GroupChatManager.h"

@interface CreateGroupViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *descripText;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UITextField *roomNameText;

@end



@implementation CreateGroupViewController


- (IBAction)addUserAct:(UIButton *)sender {
}

- (IBAction)doneBtnAct:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if (self.userText.text.length == 0 ) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入正确的用户名" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:sure];
        
        if (self.roomNameText.text.length == 0) {
            [alert setMessage:@"房间名不能为空"];
        }
        
        [self presentViewController:alert animated:YES completion:^{
            //
        }];
        
        return;
    }
    
    NSString *roomName = [NSString stringWithFormat:@"%@@conference.%@",self.roomNameText.text,[UserOperation shareduser].hostUrl];
    //NSString *roomName = [NSString stringWithFormat:@"%@@%@",self.roomNameText.text,[UserOperation shareduser].hostUrl];

    NSString *password = self.passwordText.text;
    NSString *userJid = self.userText.text;
    NSString *descripe = self.descripText.text;


    
  
    
    GroupChatManager *manager = [GroupChatManager sharedGroupManager];
    
    @HYWeakObj(manager);
    @HYWeakObj(self);
    
    [GroupChatManager sharedGroupManager].inviteFriendsBlock = ^(XMPPRoom *room){
      
        [Weakmanager inviteUser:userJid toRoom:room withMessage:descripe];
    };
    
    if (Weakself.isInviteMember) {
        
        NSDictionary *chatRoomsDict = Weakmanager.chatRoomDict;
        if (chatRoomsDict[roomName] == nil) return;
        ChatRoom *room = chatRoomsDict[roomName];
        NSLog(@"room = %@",room);
        //[Weakmanager inviteUser:userJid toRoom:room.xmpproom withMessage:descripe];
        [Weakmanager inviteMember:userJid toChatRoomJid:roomName reason:descripe withPassword:password];
        

    }else{
        //创建房间
        [[GroupChatManager sharedGroupManager]creatChatRoom:roomName withPassword:password];
    }
    
   
    
    /*
     2016-02-04 11:50:06.499 J1-IM[2439:595331] 判断进入房间成功没？ presence = <presence xmlns="jabber:client" to="wushangkun@127.0.0.1/2heckep2ht" from="room4@conference.127.0.0.1/wushangkun"><x xmlns="http://jabber.org/protocol/muc#user"><item jid="wushangkun@127.0.0.1/2heckep2ht" affiliation="owner" role="moderator"></item><status code="110"></status><status code="100"></status><status code="201"></status></x></presence>
     2016-02-04 11:50:06.499 J1-IM[2439:595331] xmppRoomDidCreate
     2016-02-04 11:50:06.500 J1-IM[2439:595331] xmppRoomDidJoin
     2016-02-04 11:50:14.786 J1-IM[2439:595331] didFetchBanList
     2016-02-04 11:50:14.786 J1-IM[2439:595331] didFetchMembersList
     2016-02-04 11:50:14.787 J1-IM[2439:595331] didFetchModeratorsList
     */

}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.isInviteMember) {
        //
        self.navigationItem.title = @"邀请好友";
    }else{
        //创建房间
        self.navigationItem.title = @"创建房间";
    }
    
    self.userText.delegate = self;
    self.descripText.delegate = self;
    self.passwordText.delegate = self;
    self.roomNameText.delegate = self;

    
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
   // [self.userText resignFirstResponder];
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
