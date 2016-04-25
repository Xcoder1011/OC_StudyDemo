//
//  ViewController.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/18.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "ViewController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"
#import "SixViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end


@interface CellModel : NSObject
@property (nonatomic , strong) NSString *name;
@property (nonatomic , copy) void(^clickBlock)();
@end

@implementation CellModel
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDataSource];
    
    self.navigationItem.title = @"OC与JS交互";
    self.tableView = ({
        UITableView *tbView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tbView.rowHeight = 49;
        tbView.delegate = self;
        tbView.dataSource = self;
        tbView;
    });
    [self.view addSubview:self.tableView];
}

-(NSArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSArray new];
    }
    return _dataArray;
}

-(void)setDataSource{

    __weak typeof(self) weakSelf = self;
    CellModel *model1 = [[CellModel alloc]init];
    model1.name = @"加载本地的js,html,css";
    model1.clickBlock = ^{
        [weakSelf.navigationController pushViewController:[[OneViewController alloc]init] animated:YES];
    };
    
    CellModel *model2 = [[CellModel alloc]init];
    model2.name = @"加载网络js文件";
    model2.clickBlock = ^{
        [weakSelf.navigationController pushViewController:[[TwoViewController alloc]init] animated:YES];
    };
    
    CellModel *model3 = [[CellModel alloc]init];
    model3.name = @"使用js库";
    model3.clickBlock = ^{
        [weakSelf.navigationController pushViewController:[[ThreeViewController alloc]init] animated:YES];
    };
    
    CellModel *model4 = [[CellModel alloc]init];
    model4.name = @"js调用oc方法（通过对象调用类中方法）";
    model4.clickBlock = ^{
        [weakSelf.navigationController pushViewController:[[FourViewController alloc]init] animated:YES];
    };
    
    CellModel *model5 = [[CellModel alloc]init];
    model5.name = @"js调用oc方法（通过block回调）";
    model5.clickBlock = ^{
        [weakSelf.navigationController pushViewController:[[FiveViewController alloc]init] animated:YES];
    };
    
    CellModel *model6 = [[CellModel alloc]init];
    model6.name = @"oc调用js";
    model6.clickBlock = ^{
        [weakSelf.navigationController pushViewController:[[SixViewController alloc]init] animated:YES];
    };
    
    self.dataArray = @[model1,model2,model3,model4,model5,model6];
}

#pragma mark  UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

#pragma mark  UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier  = @"IdentifierCell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    CellModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    CellModel *model = self.dataArray[indexPath.row];
    if (model.clickBlock) {
        model.clickBlock();
    }
}

@end
