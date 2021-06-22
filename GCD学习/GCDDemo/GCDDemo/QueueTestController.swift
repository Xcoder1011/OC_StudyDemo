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
