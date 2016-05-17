//
//  HomeViewController.m
//  1_MVVMDemo
//
//  Created by wushangkun on 16/5/17.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "HomeViewController.h"
#import "TableViewDataSource.h"
#import "TableViewDelegate.h"

@interface HomeViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TableViewDataSource *dataSource;
@property (nonatomic, strong) TableViewDelegate *delegate;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MVVM Test";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self startRequest];
    [self.view addSubview:self.tableView];
}

//下载数据
-(void)startRequest{
    
    

}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = _delegate;
        _tableView.dataSource = _dataSource;
    }
    return _tableView;
}

-(TableViewDataSource *)dataSource{
    if (!_dataSource) {
        _dataSource = [[TableViewDataSource alloc]init];
    }
    return _dataSource;
}

-(TableViewDelegate *)delegate{
    if (!_delegate) {
        _delegate = [[TableViewDelegate alloc]init];
    }
    return _delegate;
}



@end
