//
//  ViewController.m
//  GCDDemo
//
//  Created by wushangkun on 16/4/29.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1.测试栅栏函数
    //[self dispatchBarrierAsyncDemo];
    
    // 2.模拟for循环
    //[self dispatchApplyDemo1];
    
    // 3.模拟dispatch_sync的同步效果
    //[self dispatchApplyDemo2];
    
    // 4.监视多个异步任务是否都完成
    //[self dispatchGroupWaitDemo];
    //[self dispatchGroupNotifyDemo];
    
    // 5.创建block
    //[self createDispatchBlock];
    
    // 6.dispatch block来设置等待时间
    //[self dispatch_Block_Wait];
    
    // 7.dispatch_block_notify监视指定dispatch block结束，然后再加入一个block到队列中。
    //[self dispatch_Block_Notify];
    
    // 8. 对dispatch block取消
    //[self dispatch_Block_Cancel];
    // 9. 监视文件夹内文件变化
    [self dispatch_Source_Set_Event];

}

#pragma mark -- 基本概念
-(void)learningGCD{

    // -------------   1. 系统标准的两个队列    -----------
    
    // 1.1 全局队列，并行队列
    /*
     * 系统提供四个全局并发队列，这四个队列有这对应的优先级，用户是不能够创建全局队列的，只能获取。
     */
    dispatch_queue_t globalQueue ;
    globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    // 1.2 主队列，主线程中的
    /*
     * 全局可用的serial queue，在应用程序主线程上执行任务。
     */
    dispatch_queue_t mainQueue ;
    mainQueue  = dispatch_get_main_queue();
    
    
    
    // -------------   2. 创建自定义队列    -----------
    
    // 2.1 串行队列
    /*
     * Serial: 又叫private dispatch queues，同时只执行一个任务, Serial queue常用于同步访问特定的资源或数据
     * label: 第一个自定义的队列名
     * attr : 第二个参数是队列类型,默认NULL或者DISPATCH_QUEUE_SERIAL或者DISPATCH_QUEUE_CONCURRENT
     */
    dispatch_queue_t serialQue =  dispatch_queue_create("com.j1.serialqueue", DISPATCH_QUEUE_SERIAL);
    
    
    // 2.2 并行队列
    /*
     * Concurrent：又叫global dispatch queue，可以并发的执行多个任务，但执行完成顺序是随机的
     */
    dispatch_queue_t concurrentQue = dispatch_queue_create("com.j1.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    
    
    // 2.3 设置自定义队列的优先级
    /*
     * 可以通过dipatch_queue_attr_make_with_qos_class或dispatch_set_target_queue方法设置队列的优先级
     */
    
    //方法一：dipatch_queue_attr_make_with_qos_class
    dispatch_queue_attr_t serialqueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -1);
    dispatch_queue_t mySerialQueue = dispatch_queue_create("com.j1.myserialqueue", serialqueAttr);
    
    //方法二：dispatch_set_target_queue
    dispatch_queue_t targetqueue = dispatch_queue_create("com.j1.settargetqueue", NULL); //需要设置优先级的queue
    dispatch_queue_t referQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0); //参考优先级
    dispatch_set_target_queue(targetqueue, referQueue); //设置queue和referQueue的优先级一样
    
    
    // 2.4 设置队列层级体系
    /*
     * dispatch_set_target_queue : 可以设置优先级，也可以设置队列层级体系
     * 比如让多个串行和并行队列在统一一个串行队列里串行执行
     */
    dispatch_queue_t serialqueue1 = dispatch_queue_create("com.j1.serialqueue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t serialqueue2 = dispatch_queue_create("com.j1.serialqueue2", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrentqueue = dispatch_queue_create("com.j1.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_set_target_queue(serialqueue2, serialqueue1);
    dispatch_set_target_queue(concurrentqueue, serialqueue1);
    
    dispatch_async(serialqueue2, ^{
        NSLog(@"1");
        [NSThread sleepForTimeInterval:3.f];
    });
    dispatch_async(serialqueue2, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:2.f];
    });
    dispatch_async(serialqueue2, ^{
        NSLog(@"3");
        [NSThread sleepForTimeInterval:1.f];
    });
    
    
    
    // -------------   3. 同步异步线程创建    -----------
    
    // 串行与并行针对的是队列，而同步与异步，针对的则是线程
    // 3.1 同步线程
    dispatch_sync(serialQue , ^{
        
        // 同步线程要阻塞当前线程，必须要等待同步线程中的任务执行完，返回以后，才能继续执行下一任务
        // 异步线程则是不用等待。
    });
    
    //3.2 异步线程
    dispatch_async(concurrentQue, ^{
        //
    });
    
    
    
    // -------------——   4. 队列的类型    -----------——
    
    // 队列默认是串行的，如果设置改参数为NULL会按串行处理，只能执行一个单独的block，
    // 队列也可以是并行的，同一时间执行多个block
    
    // 4.1  5种队列，主队列（main queue）,四种通用调度队列，自己定制的队列。四种通用调度队列为:
    /*
     __QOS_ENUM(qos_class, unsigned int,
     QOS_CLASS_USER_INTERACTIVE: 等级表示任务需要被立即执行提供好的体验，用来更新UI，响应事件等。这个等级最好保持小规模。
     QOS_CLASS_USER_INITIATED: 等级表示任务由UI发起异步执行。适用场景是需要及时结果同时又可以继续交互的时候。
     QOS_CLASS_DEFAULT
     QOS_CLASS_UTILITY : 表示需要长时间运行的任务，伴有用户可见进度指示器。经常会用来做计算，I/O，网络，持续的数据填充等任务。这个任务节能。
     QOS_CLASS_BACKGROUND :表示用户不会察觉的任务，使用它来处理预加载，或者不需要用户交互和对时间不敏感的任务。
     QOS_CLASS_UNSPECIFIED
     );
     */
    
    
    // 4.2  何时使用何种队列类型？
    // 主队列: 队列中有任务完成需要更新UI时,dispatch_after在这种类型中使用。
    // 并发队列: 用来执行与UI无关的后台任务，dispatch_sync放在这里，方便等待任务完成进行后续处理或和dispatch barrier同步。
    // 自定义顺序队列：顺序执行后台任务并追踪它时。这样做同时只有一个任务在执行可以防止资源竞争。dipatch barriers解决读写锁问题的放在这里处理。
}



// -------------——   5. 常见函数   -----------——

// 5.1 dispatch_once用法
/*
 * 单例写法
 * dispatch_once_t要是全局或static变量，保证dispatch_once_t只有一份实例
 */
+(UIColor *)boringColor {
    static UIColor *color;
    //只运行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor redColor];
    });
    return color;
}


// 5.2 dispatch_async用法
/*
 * 异步的API调用dispatch_async()
 * 避免界面会被一些耗时的操作卡死，
 */
-(void)progressImage:(UIImage *)image completionHandle:(void(^)(bool success))handle{
    
    dispatch_queue_t serialQueue1 = dispatch_queue_create("com.j1.serialqueue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t resultQueue = dispatch_queue_create("com.j1.serialqueue1", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(serialQueue1, ^{
        // do actual processing here
        dispatch_async(resultQueue, ^{
            handle(YES);
        });
    });
    
    // 读取网络数据，大数据IO，还有大量数据的数据库读写，这时需要在另一个线程中处理，然后通知主线程更新界面
    
    // ---- 代码框架 ----
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // do 耗时的操作 ...
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // do 刷新UI ...
        });
    });
    
    // 下载图片的示例：
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 下载耗时操作
        NSURL *url = [NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
        NSData *data = [[NSData alloc]initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc]initWithData:data];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新界面
                // self.imageView.image = image;
            });
        }
    });
}


// 5.3 dispatch_after : 延后执行
/*
 * dispatch_after只是延时提交block，不是延时立刻执行。
 * dispatch_time_t dispatch_time ( dispatch_time_t when, int64_t delta );
 * when : 第一个参数为DISPATCH_TIME_NOW表示当前
 * delta : 第二个参数的delta表示纳秒，一秒对应的纳秒为1000000000
 */
-(void)refreshData{
    // 模拟加载数据
    dispatch_time_t poptime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 *NSEC_PER_SEC));
    
    dispatch_after(poptime, dispatch_get_main_queue(), ^{
        // 2秒后停止刷新
        // [self endfresh];
    });
    
    // #define NSEC_PER_SEC 1000000000ull //每秒有多少纳秒
    // #define USEC_PER_SEC 1000000ull    //每秒有多少毫秒
    // #define NSEC_PER_USEC 1000ull      //每毫秒有多少纳秒
    
    // ---------> 表示1秒:
    //    dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    //    dispatch_time(DISPATCH_TIME_NOW, 1000 * USEC_PER_SEC);
    //    dispatch_time(DISPATCH_TIME_NOW, USEC_PER_SEC * NSEC_PER_USEC);  //表示1秒
    
}



// 5.4 dispatch_barrier_async : 栅栏函数
/*
 * Dispatch Barrier解决多线程并发读写同一个资源发生死锁
 * dispatch_barrier_async: 确保提交的闭包是指定队列中在特定时段唯一在执行的一个。
 * 注意: dispatch_barrier_async只在自己创建的队列上有这种作用，在全局并发队列或串行队列上，效果和dispatch_async一样
 */
-(void)dispatchBarrierAsyncDemo{
    // 创建一个并行队列
    dispatch_queue_t dataQueue = dispatch_queue_create("com.j1.dataQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 1");
    });
    
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 2");         //(1).先并行输出read data 1 , read data 2
    });
    
    // 在 并行 队列中 等待 前面的完成，再执行barrier后面的
    // 当在并发队列中遇到一个barrier, 他会延迟执行barrier的block
    // 等待所有在barrier之前提交的blocks执行结束。 这时，barrier block自己开始执行
    dispatch_barrier_async(dataQueue, ^{
        NSLog(@"write data 1");        //(2).现在就只会执行这一个操作,执行完成后，即输出 write data 1
    });
    
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 3");         //(3).最后该并行队列恢复原有执行状态，继续并行执行,并行输出read data 3 ， read data 4
    });
    
    dispatch_async(dataQueue, ^{
        NSLog(@"write data 4");
    });
    /*
     2016-04-29 10:41:11.203 GCDDemo[1118:471931] read data 2
     2016-04-29 10:41:11.203 GCDDemo[1118:471343] read data 1
     2016-04-29 10:41:15.129 GCDDemo[1118:471343] write data 1
     2016-04-29 10:41:16.480 GCDDemo[1118:471343] read data 3
     2016-04-29 10:41:16.480 GCDDemo[1118:471931] write data 4
     */
}


// 5.5 dispatch_apply进行快速迭代 : 模拟for循环
/*
 * 该函数按指定的次数将指定的Block追加到指定的Dispatch Queue中,并等到全部的处理执行结束
 */
#pragma mark -- 1.模拟for循环
-(void)dispatchApplyDemo1{
    
    NSArray *array = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j"];
    // 创建一个全局队列
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 模拟for循环,对数组里的全部元素进行处理
    dispatch_apply([array count], queue, ^(size_t index) {
        //第一个参数是迭代次数，第二个是所在的队列，第三个是当前索引，dispatch_apply可以利用多核的优势，所以输出的index顺序不是一定的!
        NSLog(@"%zu: %@",index,[array objectAtIndex:index]);
    });
    
    //dispatch_apply 和 dispatch_apply_f 是同步函数,会阻塞当前线程直到所有循环迭代执行完成。当提交到并发queue时,循环迭代的执行顺序是不确定的
    NSLog(@"done"); //这里有个需要注意的是，dispatch_apply这个是会阻塞主线程的。这个log打印会在dispatch_apply都结束后才开始执行
    
    /*
     2016-04-29 10:43:20.750 GCDDemo[1147:484551] 0: a
     2016-04-29 10:43:20.750 GCDDemo[1147:485069] 1: b
     2016-04-29 10:43:20.750 GCDDemo[1147:484551] 4: e
     2016-04-29 10:43:20.750 GCDDemo[1147:485033] 3: d
     2016-04-29 10:43:20.750 GCDDemo[1147:485034] 2: c
     2016-04-29 10:43:20.751 GCDDemo[1147:484551] 6: g
     2016-04-29 10:43:20.751 GCDDemo[1147:485069] 5: f
     2016-04-29 10:43:20.751 GCDDemo[1147:484551] 9: j
     2016-04-29 10:43:20.751 GCDDemo[1147:485033] 7: h
     2016-04-29 10:43:20.751 GCDDemo[1147:485034] 8: i
     2016-04-29 10:43:23.339 GCDDemo[1147:484551] done
     */
}


#pragma mark -- 2.模拟dispatch_sync的同步效果
/*
 * @brief   推荐->在dispatch_async函数中异步执行dispatch_apply函数
 *  效果    dispatch_apply函数与dispatch_sync函数形同,会等待处理执行结束
 */
-(void)dispatchApplyDemo2{
    
    NSArray *array = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j"];
    // 创建一个全局队列
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        //1. 在dispatch_async函数中异步执行dispatch_apply函数
        dispatch_apply([array count], queue, ^(size_t index) {
            
            NSLog(@"%zu: %@",index,[array objectAtIndex:index]);
        });
        
        //2.回到主线程执行界面更新
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"回到主线程执行用户界面更新等操作");
        });
    });
    
    /*!
     * @brief  执行结果
     2016-04-29 10:44:59.138 GCDDemo[1172:495843] 2: c
     2016-04-29 10:44:59.138 GCDDemo[1172:495832] 0: a
     2016-04-29 10:44:59.138 GCDDemo[1172:495847] 1: b
     2016-04-29 10:45:02.016 GCDDemo[1172:495858] 3: d
     2016-04-29 10:45:02.017 GCDDemo[1172:495843] 4: e
     2016-04-29 10:45:02.017 GCDDemo[1172:495832] 5: f
     2016-04-29 10:45:02.017 GCDDemo[1172:495847] 6: g
     2016-04-29 10:45:02.017 GCDDemo[1172:495858] 7: h
     2016-04-29 10:45:02.018 GCDDemo[1172:495843] 8: i
     2016-04-29 10:45:02.018 GCDDemo[1172:495832] 9: j
     2016-04-29 10:45:05.493 GCDDemo[1172:495519] 回到主线程执行用户界面更新等操作
     */
    
}



// 5.6 Dispatch_groups : 专门用来监视多个异步任务
/*
 * dispatch_group_async可以实现监听一组任务是否完成，完成后得到通知执行其他的操作。
 * 当group里所有事件都完成GCD API有两种方式发送通知，第一种是dispatch_group_wait，会阻塞当前进程，等所有任务都完成或等待超时.
 * 第二种方法是使用dispatch_group_notify，异步执行闭包，不会阻塞。
 */
#pragma mark -- 方法一：dispatch_group_wait
-(void)dispatchGroupWaitDemo{
    dispatch_queue_t  concurrentQueue = dispatch_queue_create("dispatch_group_wait", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    // 比如你执行三个下载任务，当三个任务都下载完成后你才通知界面说完成
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"task 1 done"); //异步方法
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"task 2 done");
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"task 3 done");
    });
    
    // 会阻塞当前进程，等所有任务都完成或等待超时
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"all task end");
    
    /*
     * @brief 执行结果
     2016-04-29 13:49:28.813 GCDDemo[2375:988537] task 2 done
     2016-04-29 13:49:28.813 GCDDemo[2375:988547] task 1 done
     2016-04-29 13:49:28.813 GCDDemo[2375:988559] task 3 done
     2016-04-29 13:49:28.814 GCDDemo[2375:987968] all task end
     */
}

#pragma mark -- 方法二 : dispatch_group_notify
-(void)dispatchGroupNotifyDemo{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // 比如你执行三个下载任务，当三个任务都下载完成后你才通知界面说完成
    dispatch_group_async(group, queue, ^{
        NSLog(@"task 1 done");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"task 2 done");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"task 3 done");
    });

    // 使用dispatch_group_notify，异步执行闭包，不会阻塞
    dispatch_group_notify(group, queue, ^{
        NSLog(@"all task end");
    });
    /*
     2016-04-29 14:01:25.156 GCDDemo[2561:1054338] task 3 done
     2016-04-29 14:01:25.156 GCDDemo[2561:1054315] task 2 done
     2016-04-29 14:01:25.156 GCDDemo[2561:1054316] task 1 done
     2016-04-29 14:01:25.158 GCDDemo[2561:1054316] all task end
     */
}



// -------------——   6. Dispatch Block   -----------——
#pragma mark -- 创建block
-(void)createDispatchBlock{
    
    // normal way
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"run normal way");
    });
    dispatch_async(concurrentQueue, block);
    
    //QOS way
    dispatch_block_t qosBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -1, ^{
        NSLog(@"run normal way");
    });
    dispatch_async(concurrentQueue, qosBlock);
}

#pragma mark -- dispatch_block_wait
//可以根据dispatch block来设置等待时间
-(void)dispatch_Block_Wait{
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"start");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"end");
    });
    dispatch_async(concurrentQueue, block);
    
    /*
     * @param block : The dispatch block object to wait on
     * @param timeout : DISPATCH_TIME_NOW || DISPATCH_TIME_FOREVER
     *                  DISPATCH_TIME_FOREVER : 会一直等到前面任务都完成
     */
    dispatch_block_wait(block, DISPATCH_TIME_FOREVER);

    NSLog(@"now can update UI ...");
    /*
     2016-04-29 14:46:37.015 GCDDemo[2808:1166774] start
     2016-04-29 14:46:40.962 GCDDemo[2808:1166774] end
     2016-04-29 14:46:42.830 GCDDemo[2808:1166185] now can update UI ...
     */
}


#pragma mark -- dispatch_block_notify
//可以监视指定dispatch block结束，然后再加入一个block到队列中。
-(void)dispatch_Block_Notify{
    
    dispatch_queue_t serialQueue = dispatch_queue_create("dispatch_Block_Notify", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"first block end");
    });
    
    dispatch_async(serialQueue, firstBlock);
    
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"second block start");
    });
    
    /* first block执行完才在serial queue中执行second block
     * @param block : 需要监视的block
     * @param queue : 是需要提交执行的队列
     * @param notification_block : 待加入到队列中的block
     */
    dispatch_block_notify(firstBlock, serialQueue, secondBlock);
    /*
     2016-04-29 15:07:31.050 GCDDemo[2995:1235155] first block start
     2016-04-29 15:07:34.051 GCDDemo[2995:1235155] first block end
     2016-04-29 15:07:34.051 GCDDemo[2995:1235155] second block start
     */
}


#pragma mark -- dispatch_block_cancel
// iOS8后GCD支持对dispatch block的取消
-(void)dispatch_Block_Cancel{
    
    dispatch_queue_t serialQueue = dispatch_queue_create("dispatch_Block_Cancel", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"first block end");
    });
    
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"second block start");
    });
    
    dispatch_async(serialQueue, firstBlock);
    dispatch_async(serialQueue, secondBlock);
    
    //取消firstBlock
    dispatch_block_cancel(firstBlock);
    /*
     2016-04-29 15:22:14.067 GCDDemo[3154:1322627] second block start
     */

}


// -------------——   7. Dispatch IO 文件操作   -----------——
/*
 * 多个线程去读取文件的切片数据，对于大的数据文件这样会比单线程要快很多
 * dispatch io读取文件的方式类似于下面的方式:
 */

//dispatch_async(queue,^{/*read 0-99 bytes*/});
//dispatch_async(queue,^{/*read 100-199 bytes*/});
//dispatch_async(queue,^{/*read 200-299 bytes*/});

//dispatch_io_create：创建dispatch io
//dispatch_io_set_low_water：指定切割文件大小
//dispatch_io_read：读取切割的文件然后合并。


// -------------——   7. Dispatch Source GCD监视进程   -----------
/*
 * Dispatch Source用于监听系统的底层对象，比如文件描述符，Mach端口，信号量等
 
 * DISPATCH_SOURCE_TYPE_DATA_ADD      ： 数据增加
 * DISPATCH_SOURCE_TYPE_DATA_OR       ： 数据OR
 * DISPATCH_SOURCE_TYPE_MACH_SEND     ： Mach端口发送
 * DISPATCH_SOURCE_TYPE_MACH_RECV     ： Mach端口接收
 * DISPATCH_SOURCE_TYPE_MEMORYPRESSURE： 数据增加
 * DISPATCH_SOURCE_TYPE_PROC          ： 进程事件
 * DISPATCH_SOURCE_TYPE_READ          ： 读数据
 * DISPATCH_SOURCE_TYPE_SIGNAL        ： 信号
 * DISPATCH_SOURCE_TYPE_TIMER         ： 定时器
 * DISPATCH_SOURCE_TYPE_VNODE         ： 文件系统变化
 * DISPATCH_SOURCE_TYPE_WRITE         ： 文件写入
 */

// 方法：
// dispatch_source_create：创建dispatch source，创建后会处于挂起状态进行事件接收，需要设置事件处理handler进行事件处理。
// dispatch_source_set_event_handler：设置事件处理handler
// dispatch_source_set_cancel_handler：事件取消handler，就是在dispatch source释放前做些清理的事。
// dispatch_source_cancel：关闭dispatch source，设置的事件处理handler不会被执行，已经执行的事件handler不会取消。

#pragma mark -- 监视文件夹内文件变化
-(void)dispatch_Source_Set_Event{
    
    NSURL *directoryURL;

    int const fd = open([[directoryURL path]fileSystemRepresentation], O_EVTONLY);
    if (fd < 0) {
        char buffer[80];
        strerror_r(errno, buffer, sizeof(buffer));
        NSLog(@"Unable to open \"%@\": %s (%d)",[directoryURL path],buffer,errno);
        return;
    }
    // DISPATCH_SOURCE_TYPE_VNODE :文件系统变化
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE , fd, DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE, DISPATCH_TARGET_QUEUE_DEFAULT);
    
    dispatch_source_set_event_handler(source, ^{
        unsigned long const data = dispatch_source_get_data(source);
        if (data & DISPATCH_VNODE_WRITE) {
            NSLog(@"The directory changed");
        }
        
        if (data & DISPATCH_VNODE_DELETE) {
            NSLog(@"The directory has been deleted");
        }
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fd);
    });
//    self.source = source;
//    dispatch_resume(self.source);
    //还要注意需要用DISPATCH_VNODE_DELETE 去检查监视的文件或文件夹是否被删除，如果删除了就停止监听

}

@end
