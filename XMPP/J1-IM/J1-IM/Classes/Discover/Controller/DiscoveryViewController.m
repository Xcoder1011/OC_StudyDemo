//
//  DiscoveryViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "GroupListViewController.h"

@interface DiscoveryViewController ()

@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"发现";
    self.view.backgroundColor = [UIColor blueColor];
    
    [self  setNavRightItemWith:@"群组" andImage:nil];
}

-(void)rightItemClick:(id)sender{
    GroupListViewController *groupCtrl =[[ GroupListViewController alloc]init];
    //self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:groupCtrl animated:YES];

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
