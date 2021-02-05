//
//  LockViewController.m
//  GCDDemo
//
//  Created by shangkun on 2021/1/4.
//  Copyright © 2021 J1. All rights reserved.
//

#import "LockViewController.h"
#import <os/lock.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>

@interface LockViewController ()
{
    NSInteger _money;
    NSInteger _tickets;
}
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) os_unfair_lock unfairLock;

@property (nonatomic, assign) OSSpinLock spinlock;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation LockViewController

#define SKLOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define SKUNLOCK(lock) dispatch_semaphore_signal(lock);


- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"多线程安全";
    self.title = @"";
    _dataArray = @[
        @{
            @"title": @"存钱取钱问题",
            @"action": @"moneyTest",
        },
        @{
            @"title": @"卖票问题",
            @"action": @"sellTicketsTest",
        },
        @{
            @"title": @"os_unfair_lock (性能高、安全、iOS10后推荐)",
            @"action": @"os_unfair_lockTest",
        },
        @{
            @"title": @"dispatch_semaphore (性能高、安全、推荐)",
            @"action": @"dispatch_SemaphoreTest",
        },
        @{
            @"title": @"pthread_mutex (互斥锁、推荐)",
            @"action": @"pthread_mutexTest",
        },
        @{
            @"title": @"OSSpinLock (自旋锁、性能高、不安全、不推荐)",
            @"action": @"moneyTest",
        },
        @{
            @"title": @"NSLock",
            @"action": @"moneyTest",
        },
        @{
            @"title": @"dispatch_queue(DISPATCH_QUEUE_SERIAL)",
            @"action": @"moneyTest",
        },
        @{
            @"title": @"NSRecursiveLock",
            @"action": @"moneyTest",
        },
        @{
            @"title": @"NSConditionLock",
            @"action": @"moneyTest",
        },
        @{
            @"title": @"@synchronized",
            @"action": @"moneyTest",
        }].mutableCopy;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark -- 存钱取钱问题

- (void)moneyTest {
    _money = 1000;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 50; i++) {
            [self saveMoney];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 50; i++) {
            [self drawMoney];
        }
    });

    /*
     理想情况下预期金钱余额依然是1000，但是发现不加锁的情况下 最终余额是990， 显然不是我们预期的数据
     
    2021-01-04 18:07:22.401551+0800 GCDDemo[5619:1835123] 存了10元，账户余额1010------- thread: <NSThread: 0x2820a0f40>{number = 4, name = (null)}
    2021-01-04 18:07:22.401797+0800 GCDDemo[5619:1835121] 取了10元，账户余额1010------- thread: <NSThread: 0x2820b81c0>{number = 5, name = (null)}
    2021-01-04 18:07:22.401797+0800 GCDDemo[5619:1835123] 存了10元，账户余额1020------- thread: <NSThread: 0x2820a0f40>{number = 4, name = (null)}
    2021-01-04 18:07:22.402127+0800 GCDDemo[5619:1835123] 存了10元，账户余额1020------- thread: <NSThread: 0x2820a0f40>{number = 4, name = (null)}
    2021-01-04 18:07:22.402306+0800 GCDDemo[5619:1835121] 取了10元，账户余额1010------- thread: <NSThread: 0x2820b81c0>{number = 5, name = (null)}
    2021-01-04 18:07:22.402437+0800 GCDDemo[5619:1835123] 存了10元，账户余额1020------- thread: <NSThread: 0x2820a0f40>{number = 4, name = (null)}
    2021-01-04 18:07:22.402580+0800 GCDDemo[5619:1835121] 取了10元，账户余额1010------- thread: <NSThread: 0x2820b81c0>{number = 5, name = (null)}
    2021-01-04 18:07:22.402916+0800 GCDDemo[5619:1835121] 取了10元，账户余额1000------- thread: <NSThread: 0x2820b81c0>{number = 5, name = (null)}
    2021-01-04 18:07:22.403116+0800 GCDDemo[5619:1835121] 取了10元，账户余额990------- thread: <NSThread: 0x2820b81c0>{number = 5, name = (null)}
     */
}

- (void)saveMoney {
    sleep(.3);
    NSInteger oldValue = _money;
    oldValue += 10;
    _money = oldValue;
    NSLog(@"存了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}

- (void)drawMoney {
    sleep(.3);
    NSInteger oldValue = _money;
    oldValue -= 10;
    _money = oldValue;
    NSLog(@"取了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}

#pragma mark -- 卖票问题

- (void)sellTicketsTest {
    
    _tickets = 300;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket];
        }
    });

    /*
     
     通过3条线程同时卖票，每条线程卖100张，最后应该全部卖完才对， 但是发现不加锁的情况下 最终剩余票数1， 显然不是我们预期的数据0
   
     2021-01-04 18:17:47.786368+0800 GCDDemo[5624:1837801] 剩余票数10------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.786510+0800 GCDDemo[5624:1837801] 剩余票数9------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.786762+0800 GCDDemo[5624:1837801] 剩余票数8------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.786868+0800 GCDDemo[5624:1837801] 剩余票数7------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.786995+0800 GCDDemo[5624:1837801] 剩余票数6------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.787169+0800 GCDDemo[5624:1837801] 剩余票数5------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.787278+0800 GCDDemo[5624:1837801] 剩余票数4------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.787507+0800 GCDDemo[5624:1837801] 剩余票数3------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.787661+0800 GCDDemo[5624:1837801] 剩余票数2------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     2021-01-04 18:17:47.787757+0800 GCDDemo[5624:1837801] 剩余票数1------- thread: <NSThread: 0x281a11880>{number = 4, name = (null)}
     
     
     os_unfair_lock(推荐🌟🌟🌟🌟🌟)
     OSSpinLock（不安全⚠️⚠️）
     dispatch_semaphore（推荐🌟🌟🌟🌟🌟）
     pthread_mutex（推荐🌟🌟🌟🌟）
     dispatch_queue(DISPATCH_QUEUE_SERIAL)（推荐🌟🌟🌟）
     NSLock（🌟🌟🌟）
     NSCondition（🌟🌟🌟）
     pthread_mutex(recursive)（🌟🌟）
     NSRecursiveLock（🌟🌟）
     NSConditionLock（🌟🌟）
     @synchronized（最不推荐）
     
     */
}

-(void)sellTicket {
    sleep(.3);
    NSInteger oldValue = _tickets;
    oldValue--;
    _tickets = oldValue;
    NSLog(@"剩余票数%zd------- thread: %@",_tickets, [NSThread currentThread]);
}

#pragma mark -- os_unfair_lock

/*
 * 是一种互斥锁，性能很高，安全，推荐使用
 * 苹果建议开发者，从iOS10.0之后，就应该用os_unfair_lock来取代OSSpinLock
 * 为了解决OSSpinLock的优先级反转问题，在os_unfair_lock中摒弃了忙等方式，使线程真正休眠的方式，来阻塞线程，也就从根本上解决了之前的问题。
 * 需要导入头文件 #import <os/lock.h>
 */
-(void)os_unfair_lockTest
{
    _money = 1000;
    // 初始化锁对象lock
    os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
    self.unfairLock = lock;
    
     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(queue, ^{
         for (int i = 0; i < 100; i++) {
             [self saveMoney_os_unfair_lock];
         }
     });
     dispatch_async(queue, ^{
         for (int i = 0; i < 100; i++) {
             [self drawMoney_os_unfair_lock];
         }
     });
    
    /*
    2021-01-04 18:42:23.462800+0800 GCDDemo[5629:1843404] 存了10元，账户余额980------- thread: <NSThread: 0x281e87940>{number = 4, name = (null)}
    2021-01-04 18:42:23.462883+0800 GCDDemo[5629:1843403] 取了10元，账户余额970------- thread: <NSThread: 0x281e88300>{number = 3, name = (null)}
    2021-01-04 18:42:23.462964+0800 GCDDemo[5629:1843404] 存了10元，账户余额980------- thread: <NSThread: 0x281e87940>{number = 4, name = (null)}
    2021-01-04 18:42:23.463201+0800 GCDDemo[5629:1843404] 存了10元，账户余额990------- thread: <NSThread: 0x281e87940>{number = 4, name = (null)}
    2021-01-04 18:42:23.463287+0800 GCDDemo[5629:1843404] 存了10元，账户余额1000------- thread: <NSThread: 0x281e87940>{number = 4, name = (null)}
     */
}

- (void)saveMoney_os_unfair_lock {
    
    // 加锁 加锁失败会阻塞线程进行等待
     os_unfair_lock_lock(&_unfairLock);
    
    sleep(.3);
    NSInteger oldValue = _money;
    oldValue += 10;
    _money = oldValue;
    
    // 解锁
    os_unfair_lock_unlock(&_unfairLock);
    NSLog(@"存了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}

- (void)drawMoney_os_unfair_lock {
    // 初始化锁对象lock
    // os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
    // 尝试加锁，加锁成功继续，加锁失败返回，继续执行后面的代码，不阻塞线程
    // bool flag = os_unfair_lock_trylock(lock);
    
    // 加锁 加锁失败会阻塞线程进行等待
    os_unfair_lock_lock(&_unfairLock);

    sleep(.3);
    NSInteger oldValue = _money;
    oldValue -= 10;
    _money = oldValue;
    
    // 解锁
    os_unfair_lock_unlock(&_unfairLock);
    NSLog(@"取了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}


#pragma mark -- dispatch_semaphore 信号量

/*
 * 信号量的初始值可以用来控制线程并发发访问的最大数量。
 * 信号量的初始值为1，代表同时允许1条线程访问资源，这样就可以达到线程同步的目的
 * 使用dispatch_semaphore_signal加1, dispatch_semaphore_wait减1,
 * 信号量的值<=0，当前线程就会进入休眠等待； 信号量的值>0往下执行后面的代码。
 */
-(void)dispatch_SemaphoreTest
{
    _money = 1000;
    
    // 初始信号量 为1，代表同时允许1条线程访问资源，
    _semaphore = dispatch_semaphore_create(1);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self saveMoney_dispatch_semaphore]; // 异步并发执行100次存钱操作
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self drawMoney_dispatch_semaphore]; //异步并发执行100次取钱操作
        }
    });
}


- (void)saveMoney_dispatch_semaphore {
    
    // 信号量 -1
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    // SKLOCK(_semaphore);
    
    sleep(.3);
    NSInteger oldValue = _money;
    oldValue += 10;
    _money = oldValue;
    
    // 信号量 +1
    dispatch_semaphore_signal(_semaphore);
    // SKUNLOCK(_semaphore);
    
    NSLog(@"存了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}

- (void)drawMoney_dispatch_semaphore {
     
    // 信号量 -1
    
    // dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    SKLOCK(_semaphore);
   
    sleep(.3);
    NSInteger oldValue = _money;
    oldValue -= 10;
    _money = oldValue;
     
    // 信号量 +1
    // dispatch_semaphore_signal(_semaphore);
    SKUNLOCK(_semaphore);

    NSLog(@"取了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}

#pragma mark -- OSSpinLock 自旋锁

/*
 * 自旋锁，性能很高，但是不推荐使用.
 * 自旋锁的原理是当加锁失败的时候，让线程处于忙等的状态（busy-wait），以此让线程停留在临界区（需要加锁的代码段）之外，一旦加锁成功，线程便可以进入临界区进行对共享资源操作。
 * 自旋锁的线程等待会处于忙等状态 （本质上是一个while（1）循环不断地去判断加锁条件）会一直占有CPU 的资源 并没有让线程真正休眠。
 * 会出现 线程 优先级反转问题。ios10 以后使用会警告️，苹果已经建议开发者停止使用自旋锁。
 * 原因：如果等待锁的线程优先级较高，它会一直占用着CPU资源，优先级低的线程就无法释放锁
 * 需要导入头文件#import <libkern/OSAtomic.h>
 * 让线程阻塞有两种方法： ① 让线程真正休眠，真正使得线程停下来，CPU不再 分配资源给线程； ② 自旋锁的忙等（busy-wait），本质上是一个while循环
 */
-(void)OSSpinLockTest
{
    _money = 1000;
    
    OSSpinLock lock = OS_SPINLOCK_INIT;
    _spinlock = lock;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self saveMoney_OSSpinLock]; // 异步并发执行100次存钱操作
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self drawMoney_OSSpinLock]; //异步并发执行100次取钱操作
        }
    });
}

- (void)saveMoney_OSSpinLock {
    
    // 加锁
    OSSpinLockLock(&_spinlock);
    
    sleep(.3);
    NSInteger oldValue = _money;
    oldValue += 10;
    _money = oldValue;
    
    // 解锁
    OSSpinLockUnlock(&_spinlock);
    
    NSLog(@"存了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}

- (void)drawMoney_OSSpinLock {
     
    // 加锁
    OSSpinLockLock(&_spinlock);
   
    sleep(.3);
    NSInteger oldValue = _money;
    oldValue -= 10;
    _money = oldValue;
     
    // 解锁
    OSSpinLockUnlock(&_spinlock);

    NSLog(@"取了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
}


#pragma mark -- pthread_mutex 互斥锁

/*
 * 互斥锁，性能高， 等待锁的线程会处于真正休眠状态
 * 导入头文件 #import <pthread.h>
 
 初始化锁的属性
 pthread_mutexattr_t attr;
 pthread_mutexattr_init(&attr);
 pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NOMAL);
 
 初始化锁
 pthread_mutex_t mutex;
 pthread_mutex_init(&mutex, &attr);
 
 尝试加锁
 pthread_mutex_trylock(&mutex);
 
 加锁
 pthread_mutex_lock(&mutex);
 
 解锁
 pthread_mutex_unlock(&mutex);
 
 销毁相关资源
 pthread_mutexattr_destroy(&attr);
 pthread_mutex_destroy(&attr);

 */

#pragma mark -- pthread_mutex 卖票问题

- (void)pthread_mutexTest {
    
    // 初始化锁的属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    //    #define PTHREAD_MUTEX_NORMAL        0
    //    #define PTHREAD_MUTEX_ERRORCHECK    1
    //    #define PTHREAD_MUTEX_RECURSIVE     2   // 递归锁
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
 
    // 初始化锁
    pthread_mutex_t mutex ;
    pthread_mutex_init(&mutex, &attr);
 
    _tickets = 300;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket];
        }
    });

    /*
     通过3条线程同时卖票，每条线程卖100张，最后应该全部卖完才对， 但是发现不加锁的情况下 最终剩余票数1， 显然不是我们预期的数据0
     */
}

//-(void)sellTicket {
//    sleep(.3);
//    NSInteger oldValue = _tickets;
//    oldValue--;
//    _tickets = oldValue;
//    NSLog(@"剩余票数%zd------- thread: %@",_tickets, [NSThread currentThread]);
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *dic = _dataArray[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"title"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.row];
    NSString *action = [dic objectForKey:@"action"];
    [self performSelector:NSSelectorFromString(action)];
}
@end
