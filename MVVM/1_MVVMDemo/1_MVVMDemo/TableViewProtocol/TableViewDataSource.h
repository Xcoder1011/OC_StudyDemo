//
//  TableViewDataSource.h
//  1_MVVMDemo
//
//  Created by wushangkun on 16/5/17.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;

@end
