//
//  GoodsModel.h
//  WebView-JS
//
//  Created by wushangkun on 16/4/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

// 需要遵守JSExport协议
@protocol GoodsModelProtocol <JSExport>

// 两个拼接起来就刚好是js的方法名
// js方法名:selectGoodsIdWithPrice , 注意withPrice里的首字母需要大写
-(void)selectGoodsId:(NSString *)goodsId withPrice:(NSString *)price;


-(void)testJSToOCWithParameter:(NSString *)param1 otherParameter:(NSString *)param2;

@end

@interface GoodsModel : NSObject <GoodsModelProtocol>

@end
