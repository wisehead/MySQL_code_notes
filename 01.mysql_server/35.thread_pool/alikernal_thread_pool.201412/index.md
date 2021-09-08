[

# 数据库内核月报 － 2014 / 12

](http://mysql.taobao.org/monthly/2014/12)

[‹](http://mysql.taobao.org/monthly/2014/12/02/)

[›](http://mysql.taobao.org/monthly/2014/12/04/)

*   [当期文章](#)

## MySQL · 性能优化 · thread pool 原理分析

大连接问题

现有mysql 处理客户端连接的方式会触发mysql 新建一个线程来处理新的连接，新建的线程会处理该连接所发送的所有 SQL 请求，即 one-thread-per-connection 的方式，其创建连接的堆栈为：

```plain
mysqld_main
	handle_connections_sockets
		create_new_thread
			create_thread_to_handle_connection
				handle_one_connection
```

线程建立后，处理请求的堆栈如下：

```plain
0 mysql_execute_command
1 0x0000000000936f40 in mysql_parse
2 0x0000000000920664 in dispatch_command
3 0x000000000091e951 in do_command
4 0x00000000008c2cd4 in do_handle_one_connection
5 0x00000000008c2442 in handle_one_connection
6 0x0000003562e07851 in start_thread () from /lib64/libpthread.so.0
7 0x0000003562ae767d in clone () from /lib64/libc.so.6
```

优点及存在的问题

在连接数较小的情况下可以很快的响应客户端的请求，但当连接数非常大时会创建很多线程，这样会引起以下问题：

1.  过多线程之间的切换会加重系统的负载，造成系统资源紧张且响应不及时；
    
2.  频繁的进行线程的创建及销毁以及线程间同时无序的竟争系统资源加重了系统的负载。
    

thread\_pool正是为了解决以上问题而产生的；

什么是thread\_pool

thread\_pool(线程池)，是指mysql 创建若干工作线程来共同处理所有连接的用户请求，用户的请求的方式不再是 ‘one thread per connection’，而是多个线程共同接收并处理多个连接的请求，在数据库的底层处理方面(mysql\_execute\_command)，单线程的处理方式和线程池的处理方式是一致的。

thread\_pool 的工作原理

启动 thread\_pool 的mysql 会创建thread\_pool\_size 个thread group , 一个timer thread, 每个thread group 最多拥有thread\_pool\_oversubscribe个活动线程，一个listener线程，listener线程负责监听分配到thread group中的连接，并将监听到的事件放入到一个queue中，worker线程从queue中取出连接的事件并执行具体的操作，执行的过程和one thread per connection 相同。timer threaad 则是为了监听各个threadgroup的运行情况，并根据是否阴塞来创建新的worker线程。

thread\_pool 建立连接的堆栈如下：

```plain
mysqld_main
handle_connections_sockets
create_new_thread
tp_add_connection
queue_put
thread group中的 worker 处理请求的堆栈如下：

0 mysql_execute_command
1 0x0000000000936f40 in mysql_parse
2 0x0000000000920664 in dispatch_command
3 0x000000000091e951 in do_command
4 0x0000000000a78533 in threadpool_process_request
5 0x000000000066a10b in handle_event
6 0x000000000066a436 in worker_main
7 0x0000003562e07851 in start_thread ()
8 0x0000003562ae767d in clone ()
```

其中worker\_main函数是woker线程的主函数，调用mysql本身的do\_command 进行消息解析及处理，和one\_thread\_per\_connection 是一样的逻辑； thread\_pool 自行控制工作的线程个数，进而实现线程的管理。

thread\_pool中线程的创建：

1.  listener线程将监听事件放入mysql放入queue中时，如果发现当前thread group中的活跃线程数active\_thread\_count为零，则创建新的worker 线程；
    
2.  正在执行的线程阻塞时，如果发现当前thread group中的活跃线程数active\_thread\_count为零，则创建新的worker 线程；
    
3.  timer线程在检测时发现没有listener线程且自上次检测以来没有新的请求时会创建新的worker线程，其中检测的时间受参数threadpool\_stall\_limit控制；
    
4.  timer线程在检测时发现没有执行过新的请求且执行队列queue 不为空时会创建新的worker线程；
    

worker线程的伪码如下：

```plain
worker_main
{
while(connection)
{
connection= get_event();
/* get_event函数用于从该线程所属thread_Group中取得事件，然后交给Handle_event函数处理，在同一Group内部，只有thread_pool_oversubscribe个线程能同时工作，多余的线程会进入sleep状态  */
if(connection)
handle_event(connection);
/* 如果是没有登录过的请求，则进行授权检查，并将其Socket绑定到thread_group中的pollfd中，并设置Connection到event中的指针上；对于登录过的，直接处理请求 */
}
// 线程销毁
}
```

thread\_pool中线程的销毁：

当从队列queue中取出的connection为空时，则此线程销毁，取connection所等待的时间受参数thread\_pool\_idle\_timeout的控制； 综上，thread\_pool通过线程的创建及销毁来自动处理worker的线程个数，在负载较高时，创建的线程数目较高，负载较低时，会销毁多余的worker线程，从而降低连接个数带来的影响的同时，提升稳定性及性能。同时，threadpool中引入了Timer 线程，主要做两个事情。

1.  定期检查每个thread\_group是否阻塞，如果阻塞，则进行唤醒或创建线程的工作；
    
2.  检查每个thread\_group中的连接是否超时，如果超时则关掉连接并释放相应的资源；
    

threadpool在使用中存在的问题：

1.  由于threadpool严格控制活跃线程数的限制，如果同时有多个大查询同时分配到了同一个thread group，则会造成此group中的请求过慢，rt 升高，最典型的就是多个binlog dump 线程同时分配到了同一个group内；
    
2.  开启了事务模式时，非事务模式的请求会放入低优先级队列，因此可能在较长时间内得不到有效处理，极端情况下，会导致实例hang 住，例如某个连接执行了 flush tables with read lock ,并且此连接的后续请求都会放入低优先级，那么有可能会造成实列hang住；
    
3.  较小并发下，threadpool 性能退化的问题；
    

[阿里云RDS-数据库内核组](http://mysql.taobao.org/)  
[欢迎在github上star AliSQL](https://github.com/alibaba/AliSQL)  
阅读： -  
[![知识共享许可协议](assets/1631063944-8232d49bd3e964f917fa8f469ae7c52a.png)](http://creativecommons.org/licenses/by-nc-sa/3.0/)  
本作品采用[知识共享署名-非商业性使用-相同方式共享 3.0 未本地化版本许可协议](http://creativecommons.org/licenses/by-nc-sa/3.0/)进行许可。