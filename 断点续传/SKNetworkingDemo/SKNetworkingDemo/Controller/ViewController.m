//
//  ViewController.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/19.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "ViewController.h"
#import "SKDownloadCell.h"
#import <AFNetworking.h>


@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController




#pragma mark -- Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubViews];
}



#pragma mark -- UITableViewDelegate & UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //SKDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:[SKDownloadCell description] forIndexPath:indexPath];
    
    SKDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:[SKDownloadCell description]];
    if (!cell) {
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:[SKDownloadCell description] owner:nil options:nil];
        for (id obj in nibArray) {
            if ([obj isKindOfClass:SKDownloadCell.self]) {
                cell = obj;
                break;
            }
        }
    }
    return cell;
}


#pragma mark -- Private method
/**
 *  初始化视图
 */
-(void)initSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource =self;
        [_tableView setRowHeight:80];
        /**
         *  用 xib 创建的 cell, 给cell里的任一控件 添加 点击手势（非代码添加）时, 运行以下registerNib代码会报错！
         *  猜测原因: 添加的手势（object） 在nib里 和 该cell是同一级，而以下代码 要求 nib 里面必须只能 包含一个UITableViewCell对象
         */
        //[_tableView registerNib:[UINib nibWithNibName:@"SKDownloadCell" bundle:nil]forCellReuseIdentifier:@"SKDownloadCell"];
    }
    return _tableView;
}

@end
