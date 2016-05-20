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
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SKDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:[SKDownloadCell description] forIndexPath:indexPath];
//    if (!cell) {
//        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"SKDownloadCell" owner:nil options:nil];
//        for (id obj in nibArray) {
//            if ([obj isKindOfClass:[SKDownloadCell class]]) {
//                cell = obj;
//                break;
//            }
//        }
//    }
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
        [_tableView registerNib:[UINib nibWithNibName:[SKDownloadCell description] bundle:[NSBundle mainBundle]]forCellReuseIdentifier:[SKDownloadCell description]];
    }
    return _tableView;
}

@end
