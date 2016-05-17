//
//  TableViewDelegate.m
//  1_MVVMDemo
//
//  Created by wushangkun on 16/5/17.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "TableViewDelegate.h"

@implementation TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}
@end
