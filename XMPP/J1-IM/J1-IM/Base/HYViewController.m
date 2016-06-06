//
//  HYViewController.m
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "HYViewController.h"

@interface HYViewController ()

@end

@implementation HYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setNavLeftItemWith:(NSString *)str andImage:(UIImage *)image {
    if ([self.navigationController.viewControllers count] ==1){
        if ([str isEqualToString:@""])
        {
            UIBarButtonItem *leftItem =[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(leftItemClick:)];
            self.navigationItem.leftBarButtonItem = leftItem;
        }
        else
        {
            UIBarButtonItem *leftItem =[[UIBarButtonItem alloc] initWithTitle:str style:UIBarButtonItemStylePlain target:self action:@selector(leftItemClick:)];
            self.navigationItem.leftBarButtonItem = leftItem;
        }
    }
}
- (void)setNavRightItemWith:(NSString *)str andImage:(UIImage *)image
{
    if ([str isEqualToString:@""])
    {
        UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    else
    {
        UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithTitle:str style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)setNavRightItems:(NSArray *)arrays {
    NSMutableArray *rightBarButtonItems =[[NSMutableArray alloc] init];

    for (NSInteger i=0; i<arrays.count; i++) {
        if (i==0) {
            UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithImage:arrays[i] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
            //rightBarButtonItems.
            [rightBarButtonItems addObject:rightItem];
        }
        if (i==1) {
            UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithImage:arrays[i] style:UIBarButtonItemStylePlain target:self action:@selector(rightItem2Click:)];
            [rightBarButtonItems addObject:rightItem];
        }
    }
    self.navigationItem.rightBarButtonItems =rightBarButtonItems;
}

- (void) HYBackClick:(id) sender {
    
    if( [self.navigationController.viewControllers objectAtIndex:0] == self ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)rightItemClick:(id)sender {
    
}
- (void)rightItem2Click:(id)sender {
    
}
- (void)leftItemClick:(id)sender{
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
