//
//  GoodsModel.m
//  WebView-JS
//
//  Created by wushangkun on 16/4/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "GoodsModel.h"

@implementation GoodsModel

-(void)selectGoodsId:(NSString *)goodsId withPrice:(NSString *)price{
    NSLog(@"curent selected ：goodsId = %@ , price = %@",goodsId,price);
}


-(void)testJSToOCWithParameter:(NSString *)param1 otherParameter:(NSString *)param2{

    NSLog(@"JS调用OC , 参数1 = %@, 参数2 = %@",param1,param2);
}

@end
