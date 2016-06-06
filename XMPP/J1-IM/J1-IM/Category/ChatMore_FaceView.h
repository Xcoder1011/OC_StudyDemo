//
//  ChatMore_FaceView.h
//  J1-IM
//
//  Created by wushangkun on 16/2/18.
//  Copyright © 2016年 J1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum :NSInteger{
    FaceType_Emoji,
    FaceType_Image,

}FaceType;

@interface ChatMore_FaceView : UIView

@property (nonatomic ,copy) void (^sendButtonBlock)(); //点击发送

@property (nonatomic ,copy) void (^sendFaceBlock)(id object, FaceType faceType);


@end
