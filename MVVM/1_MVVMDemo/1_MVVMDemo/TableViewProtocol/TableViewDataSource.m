//
//  TableViewDataSource.m
//  1_MVVMDemo
//
//  Created by wushangkun on 16/5/17.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "TableViewDataSource.h"

@implementation TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataArray.count;
}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//}
@end
