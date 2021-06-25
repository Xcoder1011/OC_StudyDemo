//
//  QueueTestController.swift
//  GCDDemo
//
//  Created by shangkun on 2018/4/29.
//  Copyright © 2018 J1. All rights reserved.
//

import UIKit

@objc class QueueTestController: UITableViewController {
    
    //    除了主队列以外的所有异步执行都会新建线程, 并发执行。
    //    在主队列下的任务不管是异步任务还是同步任务都不会开辟线程，任务只会在主线程执行。
    //    异步串行，只会开启1条线程，在子线程中顺序执行

    //    serial将会执行完一个任务才会开始下一个，
    //    concurrent触发完一个就立即进入下一个，而不管它是否已完成（同时）
    
    //    同步（sync）：不会开启新线程，在当前线程中顺序执行
    //    异步（async）：具备开启新线程能力 （主线程异步不开启新线程，非主线程异步开启新线程）

    lazy var scenes = [
        [
            "title":"主队列，同步 -> 1 死锁",
            "action":"mainQueueSync"
        ],
        [
            "title":"主队列，异步 -> 132 顺序执行，没有开启新线程",
            "action":"mainQueueAsync"
        ],
        [
            "title":"串行队列，同步 -> 123 顺序执行，没有开启新线程",
            "action":"serialQueueSync"
        ],
        [
            "title":"串行队列，异步 -> 132 顺序执行，只开启1条新线程",
            "action":"serialQueueAsync"
        ],
        [
            "title":"并行队列，同步 -> 123 顺序执行，没有开启新线程",
            "action":"concurrentQueueSync"
        ],
        [
            "title":"并行队列，异步 -> 132 并发执行，开启新线程",
            "action":"concurrentQueueAsync"
        ],
        [
            "title":"并行队列，异步 -> 1 2 333333333 异步执行需要时间",
            "action":"concurrentQueueAsync2"
        ],
        [
            "title":"并行队列，异步->同步 混合情况",
            "action":"concurrentQueue_Sync_Async"
        ],
        [
            "title":"==========================================",
            "action":""
        ],
        
        [
            "title":"Tagged Pointer",
            "action":"taggedPointerTest"
        ],
        
        [
            "title":"Tagged Pointer多线程",
            "action":"taggedPointer_queue_operation_Test"
        ],
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "queue"
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
    }
    
    @objc func mainQueueSync() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.main
        queue.sync {
            print("2  \(Thread.current)")
        }
        print("3 \(Thread.current)")
        
        /*  发生死锁，程序崩溃
         主队列的同步线程，按照FIFO的原则（先入先出），2排在3后面会等3执行完，但因为同步线程，3又要等2执行完，相互等待成为死锁。
         
         1 <NSThread: 0x282a43080>{number = 1, name = main}
         */
    }
    
    @objc func mainQueueAsync() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.main
        queue.async {
            for j in 0...10 {
                print("2 j=\(j) \(Thread.current)")
            }
        }
        print("3 \(Thread.current)")
        
        /*
         主线程顺序执行，异步实现最后执行，也在主线程中
         没有开启新线程
         
         1 <NSThread: 0x281113080>{number = 1, name = main}
         3 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=0 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=1 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=2 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=3 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=4 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=5 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=6 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=7 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=8 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=9 <NSThread: 0x281113080>{number = 1, name = main}
         2 j=10 <NSThread: 0x281113080>{number = 1, name = main}
         */
    }
    
    @objc func serialQueueSync() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.init(label: "serialQueueSync")
        queue.sync {
            for i in 0...5 {
                print("2 i=\(i) \(Thread.current)")
            }
        }
        queue.sync {
            for j in 0...5 {
                print("2 j=\(j) \(Thread.current)")
            }
        }
        print("3 \(Thread.current)")
        
        /*
         顺序执行，在主线程中
         没有开启新线程
         
         1 <NSThread: 0x282b97080>{number = 1, name = main}
         2 i=0 <NSThread: 0x282b97080>{number = 1, name = main}
         2 i=1 <NSThread: 0x282b97080>{number = 1, name = main}
         2 i=2 <NSThread: 0x282b97080>{number = 1, name = main}
         2 i=3 <NSThread: 0x282b97080>{number = 1, name = main}
         2 i=4 <NSThread: 0x282b97080>{number = 1, name = main}
         2 i=5 <NSThread: 0x282b97080>{number = 1, name = main}
         2 j=0 <NSThread: 0x282b97080>{number = 1, name = main}
         2 j=1 <NSThread: 0x282b97080>{number = 1, name = main}
         2 j=2 <NSThread: 0x282b97080>{number = 1, name = main}
         2 j=3 <NSThread: 0x282b97080>{number = 1, name = main}
         2 j=4 <NSThread: 0x282b97080>{number = 1, name = main}
         2 j=5 <NSThread: 0x282b97080>{number = 1, name = main}
         3 <NSThread: 0x282b97080>{number = 1, name = main}
         
         */
    }
    
    @objc func serialQueueAsync() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.init(label: "serialQueueAsync")
        queue.async {
            for i in 0...100 {
                print("2 i=\(i) \(Thread.current)") // 先打印完 i ，再打印 j
            }
        }
        queue.async {
            for j in 0...100 {
                print("2 j=\(j) \(Thread.current)")   // 开启一条线程，所以 j 一定在 i 后面才能打印
            }
        }
        print("3 \(Thread.current)")
        
        /*
         
         顺序执行， 不在主线程
         开启新线程
         
         1 <NSThread: 0x280466b00>{number = 1, name = main}
         3 <NSThread: 0x280466b00>{number = 1, name = main}
         2 i=0 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 i=1 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 i=2 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 i=3 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 i=4 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 i=5 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 j=0 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 j=1 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 j=2 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 j=3 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 j=4 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         2 j=5 <NSThread: 0x28040e3c0>{number = 3, name = (null)}
         
         总结：异步串行，只会开启一条线程，顺序执行， 也就是j一定在i后面才能打印
         
         */
    }
    
    @objc func concurrentQueueSync() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.init(label: "concurrentQueueSync", attributes: .concurrent)
        queue.sync {
            for i in 0...5 {
                print("2 i=\(i) \(Thread.current)")
            }
        }
        queue.sync {
            for j in 0...5 {
                print("2 j=\(j) \(Thread.current)")
            }
        }
        print("3 \(Thread.current)")
        
        /*
         顺序执行，在主线程中
         没有开启新线程
         
         1 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 i=0 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 i=1 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 i=2 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 i=3 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 i=4 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 i=5 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 j=0 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 j=1 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 j=2 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 j=3 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 j=4 <NSThread: 0x2800b2940>{number = 1, name = main}
         2 j=5 <NSThread: 0x2800b2940>{number = 1, name = main}
         3 <NSThread: 0x2800b2940>{number = 1, name = main}
         
         */
    }
    
    @objc func concurrentQueueAsync() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.init(label: "concurrentQueueAsync", attributes: .concurrent)
        queue.async {
            for i in 0...5 {
                print("2 i=\(i) \(Thread.current)")   // i和j是并发打印，没有先后顺序
            }
        }
        queue.async {
            for j in 0...5 {
                print("2 j=\(j) \(Thread.current)")
            }
        }
        print("3 \(Thread.current)")
        
        /*
         并发执行， 不在主线程
         开启新线程
         
         1 <NSThread: 0x282520740>{number = 1, name = main}
         3 <NSThread: 0x282520740>{number = 1, name = main}
         2 i=0 <NSThread: 0x282527d00>{number = 4, name = (null)}
         2 i=1 <NSThread: 0x282527d00>{number = 4, name = (null)}
         2 i=2 <NSThread: 0x282527d00>{number = 4, name = (null)}
         2 j=0 <NSThread: 0x28256db00>{number = 7, name = (null)}
         2 i=3 <NSThread: 0x282527d00>{number = 4, name = (null)}
         2 i=4 <NSThread: 0x282527d00>{number = 4, name = (null)}
         2 i=5 <NSThread: 0x282527d00>{number = 4, name = (null)}
         2 j=1 <NSThread: 0x28256db00>{number = 7, name = (null)}
         2 j=2 <NSThread: 0x28256db00>{number = 7, name = (null)}
         2 j=3 <NSThread: 0x28256db00>{number = 7, name = (null)}
         2 j=4 <NSThread: 0x28256db00>{number = 7, name = (null)}
         2 j=5 <NSThread: 0x28256db00>{number = 7, name = (null)}
         
         
         问题： 以上的 3  一定在 2 之前执行吗？？ 答案： 不一定
         
         */
    }
    
    // 求证问题：3 一定在 2 之前执行吗？？ 答案： 不一定
    
    @objc func concurrentQueueAsync2() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.init(label: "concurrentQueueAsync2", attributes: .concurrent)
        queue.async {
            for i in 0...5 {
                print("2 i=\(i) \(Thread.current)")
            }
        }
        queue.async {
            for j in 0...5 {
                print("2 j=\(j) \(Thread.current)")
            }
        }
        
        for _ in 0...20 {
            print("33333333333333 \(Thread.current)")
        }
       
        
        /*
         并发执行， 不在主线程
         开启新线程  （异步执行2不一定在最后才执行，只不过异步执行需要时间，一般慢于主线程的打印操作）
         
         1 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 i=0 <NSThread: 0x280280440>{number = 6, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 j=0 <NSThread: 0x2802897c0>{number = 7, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 j=1 <NSThread: 0x2802897c0>{number = 7, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 i=1 <NSThread: 0x280280440>{number = 6, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 j=2 <NSThread: 0x2802897c0>{number = 7, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 i=2 <NSThread: 0x280280440>{number = 6, name = (null)}
         2 j=3 <NSThread: 0x2802897c0>{number = 7, name = (null)}
         2 i=3 <NSThread: 0x280280440>{number = 6, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 i=4 <NSThread: 0x280280440>{number = 6, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 i=5 <NSThread: 0x280280440>{number = 6, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 j=4 <NSThread: 0x2802897c0>{number = 7, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         2 j=5 <NSThread: 0x2802897c0>{number = 7, name = (null)}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}
         33333333333333 <NSThread: 0x2802cc740>{number = 1, name = main}

         
         */
    }
    
    @objc func concurrentQueue_Sync_Async() {
        
        print("1 \(Thread.current)")
        let queue = DispatchQueue.global(priority: .default)
        queue.sync {
            print("2  \(Thread.current)")
        }
        queue.async {
            print("3  \(Thread.current)")
        }
        print("4  \(Thread.current)")
        queue.async {
            print("5  \(Thread.current)")
        }
        queue.sync {
            print("6  \(Thread.current)")
        }
        print("7  \(Thread.current)")
        
        /*
         答案可以为多种结果， 但是 1 2 4 6 7 的顺序是肯定的， 3和5在另外一个子线程异步执行，时间不可控
         1, 2, 4, 6, 7, 3, 5
         1, 2, 4, 6, 3, 7, 5
         1, 2, 4, 3, 6, 5, 7
         1, 2, 4, 3, 5, 6, 7

         打印结果：
         1 <NSThread: 0x280690680>{number = 1, name = main}
         2  <NSThread: 0x280690680>{number = 1, name = main}
         4  <NSThread: 0x280690680>{number = 1, name = main}
         6  <NSThread: 0x280690680>{number = 1, name = main}
         3  <NSThread: 0x2806d4f00>{number = 7, name = (null)}
         7  <NSThread: 0x280690680>{number = 1, name = main}
         5  <NSThread: 0x2806d4f00>{number = 7, name = (null)}
         
         */
    }
    
    
    // Tagged Pointer
    @objc func taggedPointerTest() {
        
        print(">>>>>>>>>>>>>> 开始打印 NSString")
        let c: Character = "a"
        var str = ""
        guard var v = c.asciiValue else { return }
        var classType = ""
        repeat {
            str.append(Character(UnicodeScalar(v)))
            let nsString = NSString(string: str)
            classType = type(of: nsString).description()
            let size = MemoryLayout.size(ofValue: nsString)
            print("字符串：\(nsString) ，字符串类型：\(classType)， 指针：\(String(format: "%p", nsString)), memory size:\(size)")
            v += 1
        } while (classType == "NSTaggedPointerString")
        
        print("\n>>>>>>>>> 类型开始变化的字符串长度为：\(str.count), 字符串：\(str)")
        for i in v ..< v+10 {
            str.append(Character(UnicodeScalar(i)))
            let nsString = NSString(string: str)
            classType = type(of: nsString).description()
            let size = MemoryLayout.size(ofValue: nsString)
            print("字符串：\(nsString) ，字符串类型：\(classType)， 指针：\(String(format: "%p", nsString)), memory size:\(size)")
        }
        
        print("\n>>>>>>>>>>>>>> 开始打印 NSNumber")
        let nums = [1, 2, 2.6, 3]
        for num in nums {
            let number = NSNumber(value: num)
            classType = type(of: number).description()
            let size = MemoryLayout.size(ofValue: number)
            print("Number：\(number) ，类型：\(classType)， 指针：\(String(format: "%p", number)), memory size:\(size)")
        }
        
        /*
         打印结果：
         
         >>>>>>>>>>>>>> 开始打印 NSString
         字符串：a ，字符串类型：NSTaggedPointerString， 指针：0x90195bc20122acf3, memory size:8
         字符串：ab ，字符串类型：NSTaggedPointerString， 指针：0x90195bc20113aceb, memory size:8
         字符串：abc ，字符串类型：NSTaggedPointerString， 指针：0x90195bc23093ace3, memory size:8
         字符串：abcd ，字符串类型：NSTaggedPointerString， 指针：0x90195bf03093acdb, memory size:8
         字符串：abcde ，字符串类型：NSTaggedPointerString， 指针：0x901969703093acd3, memory size:8
         字符串：abcdef ，字符串类型：NSTaggedPointerString， 指针：0x902a69703093accb, memory size:8
         字符串：abcdefg ，字符串类型：NSTaggedPointerString， 指针：0xa3aa69703093acc3, memory size:8
         字符串：abcdefgh ，字符串类型：NSTaggedPointerString， 指针：0x90085a0701a9d6bb, memory size:8
         字符串：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0x94592a8223f03cb3, memory size:8
         字符串：abcdefghij ，字符串类型：__NSCFString， 指针：0x281454bc0, memory size:8

         >>>>>>>>> 类型开始变化的字符串长度为：10, 字符串：abcdefghij
         字符串：abcdefghijk ，字符串类型：__NSCFString， 指针：0x2814515a0, memory size:8
         字符串：abcdefghijkl ，字符串类型：__NSCFString， 指针：0x281450b80, memory size:8
         字符串：abcdefghijklm ，字符串类型：__NSCFString， 指针：0x281451580, memory size:8
         字符串：abcdefghijklmn ，字符串类型：__NSCFString， 指针：0x2814508a0, memory size:8
         字符串：abcdefghijklmno ，字符串类型：__NSCFString， 指针：0x281a21e00, memory size:8
         字符串：abcdefghijklmnop ，字符串类型：__NSCFString， 指针：0x281a224c0, memory size:8
         字符串：abcdefghijklmnopq ，字符串类型：__NSCFString， 指针：0x281a224f0, memory size:8
         字符串：abcdefghijklmnopqr ，字符串类型：__NSCFString， 指针：0x281a22520, memory size:8
         字符串：abcdefghijklmnopqrs ，字符串类型：__NSCFString， 指针：0x281a22550, memory size:8
         字符串：abcdefghijklmnopqrst ，字符串类型：__NSCFString， 指针：0x281a22580, memory size:8

         >>>>>>>>>>>>>> 开始打印 NSNumber
         Number：1 ，类型：__NSCFNumber， 指针：0x90195bc201229cd2, memory size:8
         Number：2 ，类型：__NSCFNumber， 指针：0x90195bc201229d52, memory size:8
         Number：2.6 ，类型：__NSCFNumber， 指针：0x281451460, memory size:8
         Number：3 ，类型：__NSCFNumber， 指针：0x90195bc201229dd2, memory size:8

        */
        
        
        /*
         小结：
         1、从 64位架构处理器开始，苹果引入了标记指针（Tagged Pointer）技术；
         2、Tagged Pointer专门用来存储小对象，比如NSString、NSNumber、NSDate、NSIndexPath；
         3、__NSCFConstantString ： 常量字符串，存储在常量区，继承于 __NSCFString。相同内容的 __NSCFConstantString 对象的地址相同；
         4、__NSCFString：存储在堆区，需要维护其引用计数；
         5、NSTaggedPointerString: 字符串的值直接存储在了指针上，其初始化的引用计数为2^64-1；
         6、Tagged Pointer指针的值不再是堆区地址，而是包含该数据的值，所以它不会在堆上再开辟空间（存储在栈中），也不需要管理对象的生命周期。（简单说 就不是一个对象，没有isa指针）；
         7、Tagged Pointer位视图： 标识位 + 类标识位 + 存储数据 + 数据类型；
         8、当Tagged Pointer存储数据位不够存储该数据时，就会使用动态分配内存的方式来存储数据，此时指针指向的是堆中该对象的地址值；
         9、小数不是Tagged Pointer，而是普通的对象，指向堆中地址。
        */
       
    }
    
    var name: NSString?
    
    @objc func taggedPointer_queue_operation_Test() {
        
        let queue = DispatchQueue.global(priority: .default)
        for i in 0...1000 {
            queue.async {
                self.name = NSString("abcdefghi")
                if let name = self.name {
                    let classType = type(of: name).description()
                    let size = MemoryLayout.size(ofValue: name)
                    print("【\(i)】self.name：\(name) ，字符串类型：\(classType)， 指针：\(String(format: "%p", name)), memory size:\(size)，Thread：\(Thread.current)")
                }
            }
        }
        
        /*
         【0】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d30e00>{number = 6, name = (null)}
         【2】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d1ccc0>{number = 9, name = (null)}
         【4】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d30e00>{number = 6, name = (null)}
         【5】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d15e80>{number = 10, name = (null)}
         【1】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d1cd40>{number = 8, name = (null)}
         【8】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d15e80>{number = 10, name = (null)}
         【3】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d15f00>{number = 7, name = (null)}
         【12】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d15e80>{number = 10, name = (null)}
         【13】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d15f00>{number = 7, name = (null)}
         【9】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d1cd40>{number = 8, name = (null)}
         【14】self.name：abcdefghi ，字符串类型：NSTaggedPointerString， 指针：0xb0d65176d01db9cb, memory size:8，Thread：<NSThread: 0x282d15e80>{number = 10, name = (null)}
         
         
         总结：
         
         __attribute__((aligned(16)))
         void objc_release(id obj)
         {
             if (!obj) return;
             if (obj->isTaggedPointer()) return;
             return obj->release();
         }
         
         
         1、NSTaggedPointerString类型的字符串，值不变的情况下，其标记指针的值也不不会发生变化；
         2、源码分析：Tagged Pointer不支持release、retain、autorelease、malloc和free等操作，其初始化的引用计数为2^64-1；
         3、NSTaggedPointerString字符串进行赋值，访问的是栈中的地址，不是一个对象，直接取值操作，所以不会crash，而且效率极高。

         */
        
        
        for i in 0...1000 {
            queue.async {
                self.name = NSString("abcdefghij")
                if let name = self.name {
                    let classType = type(of: name).description()
                    let size = MemoryLayout.size(ofValue: name)
                    print("【\(i)】self.name：\(name) ，字符串类型：\(classType)， 指针：\(String(format: "%p", name)), memory size:\(size)，Thread：\(Thread.current)")
                }
            }
        }
        
        /*
         
         【1】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x280720560, memory size:8，Thread：<NSThread: 0x28122fd00>{number = 3, name = (null)}
         【0】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x280734440, memory size:8，Thread：<NSThread: 0x28125cb80>{number = 4, name = (null)}
         【5】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x28075be80, memory size:8，Thread：<NSThread: 0x28122fd00>{number = 3, name = (null)}
         【6】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x2807344e0, memory size:8，Thread：<NSThread: 0x28125cb80>{number = 4, name = (null)}
         【7】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x28075bc60, memory size:8，Thread：<NSThread: 0x28122fd00>{number = 3, name = (null)}
         【8】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x280734500, memory size:8，Thread：<NSThread: 0x28125cb80>{number = 4, name = (null)}
         【3】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x2807209e0, memory size:8，Thread：<NSThread: 0x2812545c0>{number = 7, name = (null)}
         【4】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x280720500, memory size:8，Thread：<NSThread: 0x281254580>{number = 9, name = (null)}
         【13】self.name：abcdefghij ，字符串类型：__NSCFString， 指针：0x28073d040, memory size:8，Thread：<NSThread: 0x2812545c0>{number = 7, name = (null)}
         
         
         总结：
         
         - (void)setName:(NSString *)name {
             if(_name != name) {
                 [_name release];
                 _name = [name retain]; // or [name copy]
             }
         
         1、__NSCFString存储在堆中，需要维护引用计数。self.name通过setter方法为其赋值；
         2、异步并发执行setter方法，可能就会有多条线程同时执行[_name release]，连续release两次就会造成对象的过度释放，导致Crash。
         
         */
        
        
        // 解决办法1： 加锁处理：
        let lock = NSLock()
        for i in 0...1000 {
            queue.async {
                if lock.try() {
                    lock.lock()
                }
                self.name = NSString("abcdefghij")
                if let name = self.name {
                    let classType = type(of: name).description()
                    let size = MemoryLayout.size(ofValue: name)
                    print("【\(i)】self.name：\(name) ，字符串类型：\(classType)， 指针：\(String(format: "%p", name)), memory size:\(size)，Thread：\(Thread.current)")
                }
                lock.unlock()
            }
        }
        
        
        // 解决办法2： 信号量处理
        let semphore = DispatchSemaphore(value: 1)
        for i in 0...1000 {
            queue.async {
                semphore.wait()
                self.name = NSString("abcdefghij")
                if let name = self.name {
                    let classType = type(of: name).description()
                    let size = MemoryLayout.size(ofValue: name)
                    print("【\(i)】self.name：\(name) ，字符串类型：\(classType)， 指针：\(String(format: "%p", name)), memory size:\(size)，Thread：\(Thread.current)")
                }
                semphore.signal()
            }
        }
    }
    
    // 拓展一个面试题:
    // 以下两种情形分别会发生什么？
    var number: NSNumber?
    func test() {
        
        let queue = DispatchQueue.global(priority: .default)
        
        // 情形一：
        for _ in 0...1000 {
            queue.async {
                self.number = NSNumber(1)
            }
        }
        
        // 情形二：
        for _ in 0...1000 {
            queue.async {
                self.number = NSNumber(1.1)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = scenes[indexPath.item]["title"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let function = scenes[indexPath.item]["action"] {
            let selector = Selector(function)
            if self.responds(to: selector) {
                perform(selector)
            }
        }
    }
}
