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

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, assign) pthread_mutex_t mutexlock;

@property (nonatomic, assign) pthread_mutex_t mutex_recursive_lock; // 递归锁

@property (nonatomic, assign) pthread_mutex_t condition_lock; // C条件锁

@property (nonatomic, strong) NSConditionLock *pro_condition_lock; // OC条件锁

@property (nonatomic, assign) pthread_cond_t condition; // 条件对象

@property (nonatomic, strong) NSMutableArray *testArray;

@property (nonatomic, assign) OSSpinLock spinlock;
// 存取钱串行队列
@property (nonatomic, strong) dispatch_queue_t moneyQueue;

@end

@implementation LockViewController

#define SKLOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define SKUNLOCK(lock) dispatch_semaphore_signal(lock);

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     
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
    
     
     /// 自旋锁和互斥锁的对比：
     
     1.自旋锁：
     
     特点：效率高、安全性不足、占用CPU资源大，
     适用场景：
     ① 预计线程等待锁的时间很短
     ② 加锁的代码（临界区）经常被调用，但是竞争的情况发生概率很小，对安全性要求不高
     ③ CPU资源不紧张
     ④ 多核处理器
     
     2.互斥锁：
     
     特点：安全性高、占用CPU资源小，休眠/唤醒过程要消耗CPU资源，
     适用场景：
     ① 预计线程等待锁的时间比较长
     ② 临界区有IO操作
     ③ 临界区代码复杂或者循环量大
     ④ 单核处理器
     ⑤ 临界区的竞争非常激烈，对安全性要求高
     
     
     /// 读写安全：
     
     原则： 多读单写
     ① 同一时间，只能有1个线程进行写的操作
     ② 同一时间，允许有多个线程进行读的操作
     ③ 同一时间，不允许既读又写，就是说读操作和写操作之间是互斥关系
     
     两种方案：
     方案一： pthread_rwlock:读写锁
     方案二： dispatch_barrier_async:异步栅栏调用
     
     */
    
    self.title = @"多线程安全";
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
            @"title": @"pthread_mutex (普通互斥锁、推荐)",
            @"action": @"pthread_mutexTest",
        },
        @{
            @"title": @"PTHREAD_MUTEX_RECURSIVE (递归互斥锁)",
            @"action": @"pthread_mutex_recursive_test",
        },
        @{
            @"title": @"pthread_cond_t (条件互斥锁)",
            @"action": @"pthread_cond_t_test",
        },
        @{
            @"title": @"OSSpinLock (自旋锁、性能高、不安全、不推荐)",
            @"action": @"moneyTest",
        },
        @{
            @"title": @"GCD串行队列 DISPATCH_QUEUE_SERIAL",
            @"action": @"dispatch_queue_serial_Test",
        },
        @{
            @"title": @"NSLock (普通锁)",
            @"action": @"pthread_mutexTest",
        },
        @{
            @"title": @"NSRecursiveLock (递归锁)",
            @"action": @"pthread_mutex_recursive_test",
        },
        @{
            @"title": @"NSConditionLock (条件锁)",
            @"action": @"nsConditionLockTest",
        },
        @{
            @"title": @"@synchronized (性能最差, 不推荐)",
            @"action": @"synchronizedTest",
        },
        @{
            @"title": @"数据读写 (dispatch_barrier_async)",
            @"action": @"dispatch_barrier_async_test",
        },
    ].mutableCopy;
    
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

#pragma mark -- GCD串行队列 dispatch_queue(DISPATCH_QUEUE_SERIAL)

-(void)dispatch_queue_serial_Test
{
    _money = 1000;
    
    self.moneyQueue = dispatch_queue_create("moneyQueue", DISPATCH_QUEUE_SERIAL);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self saveMoney_dispatch_queue_serial]; // 异步并发执行100次存钱操作
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self drawMoney_dispatch_queue_serial]; //异步并发执行100次取钱操作
        }
    });
}

- (void)saveMoney_dispatch_queue_serial {
    
    dispatch_sync(self.moneyQueue, ^{
        sleep(.3);
        NSInteger oldValue = _money;
        oldValue += 10;
        _money = oldValue;
        NSLog(@"存了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
    });
}

- (void)drawMoney_dispatch_queue_serial {
     
    dispatch_sync(self.moneyQueue, ^{
        sleep(.5);
        NSInteger oldValue = _money;
        oldValue -= 10;
        _money = oldValue;
        NSLog(@"取了10元，账户余额%zd------- thread: %@",_money, [NSThread currentThread]);
    });
}

#pragma mark -- OSSpinLock 自旋锁

/*
 * 自旋锁，性能很高，但是不推荐使用.
 * 自旋锁的原理是当加锁失败的时候，让线程处于忙等的状态（busy-wait），以此让线程停留在临界区（需要加锁的代码段）之外，一旦加锁成功，线程便可以进入临界区进行对共享资源操作。
 * 自旋锁的线程等待会处于忙等状态 （本质上是一个while（1）循环不断地去判断加锁条件）会一直占有CPU 的资源 并没有让线程真正休眠。
 * 在线程优先级的作用下，会出现 线程 优先级反转问题。ios10 以后使用会警告️，苹果已经建议开发者停止使用自旋锁。
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
 * mutex普通锁，mutex递归锁、mutex条件锁，都是基于C语言的API
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

#pragma mark -- pthread_mutex （互斥锁）卖票问题

- (void)pthread_mutexTest {
    
    // 初始化锁的属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    //    #define PTHREAD_MUTEX_NORMAL        0   // 普通互斥锁
    //    #define PTHREAD_MUTEX_ERRORCHECK    1   // 检查错误锁
    //    #define PTHREAD_MUTEX_RECURSIVE     2   // 递归互斥锁
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
 
    // 初始化锁
    pthread_mutex_t mutex ;
    pthread_mutex_init(&mutex, &attr);
    _mutexlock = mutex;
    
    // 给锁设定默认属性， 用一句代码 pthread_mutex_init(mutex, NULL);
    // 参数NULL表示的就是初始化一个普通的互斥锁
    
    _tickets = 300;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket_pthread_mutex];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket_pthread_mutex];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket_pthread_mutex];
        }
    });
}

-(void)sellTicket_pthread_mutex {
    
    pthread_mutex_lock(&_mutexlock);
    
    sleep(.3);
    NSInteger oldValue = _tickets;
    oldValue--;
    _tickets = oldValue;
    
    pthread_mutex_unlock(&_mutexlock);
    
    NSLog(@"剩余票数%zd------- thread: %@",_tickets, [NSThread currentThread]);
}

#pragma mark -- pthread_mutex （递归互斥锁）

- (void)pthread_mutex_recursive_test {
    
    pthread_mutex_t mutex;
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    
    // 普通互斥锁：
    // pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL); // 普通互斥锁
    
    // 如果使用的是普通互斥锁，两个方法使用的是同一个锁， 那么会出现死锁的情况
    // 控制台只打印了 第一个方法 -[LockViewController recursiveFunction1]
    // 原因：执行第一个方法1 ，成功加锁， 此时执行方法2， 准备加锁的时候，发现_mutex_recursive_lock 并未解开，加锁失败，开始等待， 导致方法1的解锁代码不会执行，造成死锁
    // 解决：给两个方法加上不同的锁对象就可以解决
    
    
    // 递归互斥锁：
    // 对于同一个锁对象来说，允许重复的加锁，重复的解锁，
    // 因为对于一个有出口的递归函数来说，函数的调用次数 = 函数的退出次数
    // 加锁的次数pthread_mutex_lock和解锁的次数pthread_mutex_unlock是相等的，所以递归函数结束时，所有的锁都会被解开。
    // 注意： 递归锁只是针对在相同的线程里面可以重复加锁和解锁 ！！！
    // 也就是除了单线程的递归函数调用，在其他场景下的重复加锁 / 解锁，递归锁起不了重复加锁的作用
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); // 递归互斥锁
    
    pthread_mutex_init(&mutex, &attr);
    _mutex_recursive_lock = mutex;
    
    [self recursiveFunction1];
}

- (void)recursiveFunction1 {
    
    pthread_mutex_lock(&(_mutex_recursive_lock));
    
    NSLog(@"%s", __func__);
    [self recursiveFunction2];
    
    pthread_mutex_unlock(&_mutex_recursive_lock);
}

- (void)recursiveFunction2 {
    
    pthread_mutex_lock(&(_mutex_recursive_lock));
    
    NSLog(@"%s", __func__);
    
    pthread_mutex_unlock(&_mutex_recursive_lock);
}


#pragma mark -- pthread_cond_t （互斥锁条件）

/*
 
pthread_mutex_t mutex;
——定义一个锁对象
pthread_mutex_init(&mutex, NULL);
——初始化锁对象
pthread_cond_t condition;
——定义一个条件对象
pthread_cond_init(&condition, NULL);
——初始化条件对象
pthread_cond_wait(&condition, &mutex);
——等待条件
pthread_cond_signal(&condition);
——激活一个等待该条件的线程
pthread_cond_broadcast(&condition);
——激活所有等待条件的线程
pthread_mutex_destroy(&mutex);
——销毁锁对象
pthread_cond_destroy(&condition);
——销毁条件对象
 
 */

- (void)pthread_cond_t_test {
    
//    pthread_cond_t 实现了一种线程与线程之间的依赖关系，
    
//    我们在remove方法里面对数组dataArr进行删除元素操作
//    在add方法里面对dataArr进行元素添加操作
//    并且要求，如果dataArr的元素个数为0，则不能进行删除操作
    
    pthread_mutex_t mutex;
    // 初始化属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
    // 初始化锁
    pthread_mutex_init(&mutex, &attr);
    _condition_lock = mutex;
    
    // 初始化条件
    pthread_cond_init(&_condition, NULL);
    
    _testArray = [NSMutableArray array];
    
    NSThread *removeThread = [[NSThread alloc] initWithTarget:self selector:@selector(_remove) object:nil];
    [removeThread setName:@"_remove"];
    [removeThread start];
    
    sleep(.1);
    
    NSThread *addThread = [[NSThread alloc] initWithTarget:self selector:@selector(_add) object:nil];
    [addThread setName:@"_add"];
    [addThread start];
    
    /*
    2021-01-05 14:45:33.711452+0800 GCDDemo[2604:1203779] 加锁成功，开始_remove， name = _remove
    2021-01-05 14:45:33.711699+0800 GCDDemo[2604:1203779] testArray没有元素，开始等待.......
     
    2021-01-05 14:45:33.712528+0800 GCDDemo[2604:1203780] 加锁成功，开始_add， name = _add
    2021-01-05 14:45:35.718075+0800 GCDDemo[2604:1203780] _add成功，testArray内还剩1个元素
    2021-01-05 14:45:35.718573+0800 GCDDemo[2604:1203780] 发送条件信号
    2021-01-05 14:45:35.719178+0800 GCDDemo[2604:1203780] 解锁成功，_add线程结束, name = _add
     
    2021-01-05 14:45:35.719710+0800 GCDDemo[2604:1203779] ---->接受到条件更新信, testArray有了元素，继续删除操作.......
    2021-01-05 14:45:35.720083+0800 GCDDemo[2604:1203779] _remove成功，testArray内还剩0个元素
    2021-01-05 14:45:35.720314+0800 GCDDemo[2604:1203779] 解锁成功，_remove线程结束, name = _remove
     */
}

- (void)_remove {
    
    pthread_mutex_lock(&_condition_lock);
    
    NSLog(@"加锁成功，开始_remove， name = %@",[NSThread currentThread].name);
    
    if (self.testArray.count == 0) {
        NSLog(@"testArray没有元素，开始等待....... ");
        pthread_cond_wait(&_condition, &_condition_lock);  // 这句代码首先会解锁当前线程，然后休眠当前线程以等待条件信号，
        // pthread_cond_t 会在_remove线程内重新加锁，继续_remove线程的后续操作，并最终解锁。
        NSLog(@"---->接受到条件更新信, testArray有了元素，继续删除操作....... ");
    }
    
    [self.testArray removeLastObject];
    NSLog(@"_remove成功，testArray内还剩%lu个元素",(unsigned long)self.testArray.count);
    
    pthread_mutex_unlock(&_condition_lock);
    NSLog(@"解锁成功，_remove线程结束, name = %@",[NSThread currentThread].name);
}

- (void)_add {
    
    pthread_mutex_lock(&_condition_lock);
    
    NSLog(@"加锁成功，开始_add， name = %@",[NSThread currentThread].name);
    
    sleep(2);
    
    [self.testArray addObject:@1];
    NSLog(@"_add成功，testArray内还剩%lu个元素",(unsigned long)self.testArray.count);
    
    // 发送条件信号
    NSLog(@"发送条件信号");
    pthread_cond_signal(&_condition);
    
    pthread_mutex_unlock(&_condition_lock);
    NSLog(@"解锁成功，_add线程结束, name = %@",[NSThread currentThread].name);
}


#pragma mark -- NSLock （封装了pthread_mutex_t）
#pragma mark -- NSRecursiveLock 递归锁
#pragma mark -- NSCondition 条件锁

/*
 mutex普通锁，mutex递归锁、mutex条件锁，都是基于C语言的API
 苹果在此基础上，进行了一层面向对象封装，为开发者供了对应的OC锁如下:

 NSLock—>封装了pthread_mutex_t（attr = 普通）
 NSRecursiveLock—>封装了pthread_mutex_t（attr = 递归）
 NSCondition—> 封装了pthread_mutex_t + pthread_cond_t
 
 // 普通锁
 NSLock *lock = [[NSLock alloc] init];
 [lock lock];
 [lock unlock];
 
 // 递归锁
 NSRecursiveLock *rec_lock = [[NSRecursiveLock alloc]
 [rec_lock lock];
 [rec_lock unlock];
 
 // 条件锁
 NSCondition *condition = [[NSCondition alloc] init];
 [self.condition lock];
 [self.condition wait];
 [self.condition signal];
 [self.condition unlock];
 
 */

#pragma mark -- NSConditionLock 升级版条件锁

/*
 * 代码实现的效果就是_one方法先执行，再执行_two方法，最后执行_three方法。
 * 因为三个方法是在三个不同的子线程里面，所以这里精确控制了三条线程的先后执行顺序，或者说依赖关系。
 */
-(void)nsConditionLockTest
{
    _pro_condition_lock = [[NSConditionLock alloc] initWithCondition:1];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(_one) object:nil] start];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(_two) object:nil] start];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(_three) object:nil] start];
    
//    2021-01-05 15:38:46.570685+0800 GCDDemo[2618:1215367] -[LockViewController _one]
//    2021-01-05 15:38:47.576478+0800 GCDDemo[2618:1215368] -[LockViewController _two]
//    2021-01-05 15:38:48.582232+0800 GCDDemo[2618:1215369] -[LockViewController _three]
}

- (void)_one {
    [self.pro_condition_lock lock]; // 不带条件 直接加锁
    NSLog(@"%s", __func__);
    sleep(1);
    [self.pro_condition_lock unlockWithCondition:2]; // _condition == 2
}

- (void)_two {
    [self.pro_condition_lock lockWhenCondition:2]; // _condition != 2， 线程阻塞
    // 当_condition == 2时， 加锁成功，线程继续
    NSLog(@"%s", __func__);
    sleep(1);
    [self.pro_condition_lock unlockWithCondition:3]; // _condition == 3
}

- (void)_three {
    [self.pro_condition_lock lockWhenCondition:3];  // _condition != 3， 线程阻塞
    // 当_condition == 3时， 加锁成功，线程继续
    NSLog(@"%s", __func__);
    [self.pro_condition_lock unlock];
}

#pragma mark -- @synchronized 性能最差

/*
 * @synchronized内部封装了数组，字典（哈希表）、C++的数据结构等一系列复杂数据结构，导致它的实际性能特别低下
 * @synchronized内部最终使用的是pthread_mutex_t，并且是递归的
 */

// @synchronized(self) --> objc_sync_enter(id obj) --> 利用函数id2data(obj, ACQUIRE), 将obj作为key，从哈希表/字典sDataLists里面取出对应的SyncData列表，得到SyncData* data
//  -->通过data->mutex拿到最终的锁mlock -->加锁 mlock.lock()
//
// -------------- 加锁临界区代码 ----------------
//
// 解锁 mlock.unlock() --> id2data(obj, ACQUIRE) --> objc_cync_exit(id obj)退出

-(void)synchronizedTest
{
    _tickets = 300;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket_synchronized];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket_synchronized];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 100; i++) {
            [self sellTicket_synchronized];
        }
    });
}

- (void)sellTicket_synchronized {
    @synchronized (self) {
        sleep(.3);
        NSInteger oldValue = _tickets;
        oldValue--;
        _tickets = oldValue;
        NSLog(@"剩余票数%zd------- thread: %@",_tickets, [NSThread currentThread]);
    }
}

#pragma mark -- 数据读写 (dispatch_barrier_async)

- (void)dispatch_barrier_async_test {
    
    dispatch_queue_t read_write_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 20; i++) {
        
        dispatch_async(read_write_queue, ^{
            [self _read];
        });
        
        dispatch_async(read_write_queue, ^{
            [self _read];
        });
        
        dispatch_async(read_write_queue, ^{
            [self _read];
        });
        dispatch_barrier_async(read_write_queue, ^{
            [self _write];
        });
    }
}

- (void)_read {
    sleep(.5);
    NSLog(@"_read");
}

- (void)_write {
    sleep(1);
    NSLog(@"_write");
}

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
    if ([self respondsToSelector:NSSelectorFromString(action)]) {
        [self performSelector:NSSelectorFromString(action)];
    }
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutexlock);
}

@end
