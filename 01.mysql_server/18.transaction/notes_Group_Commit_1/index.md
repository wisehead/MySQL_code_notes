# [MySQL 5.6：Binlog Group Commit（一）]

## 什么是组提交？

基本的想法是：

*   多个线程，每一个线程处理一个事务.
*   当每个事务都执行完Prepare-Commit大部分操作，需要写盘时，排队等待日志文件（此处不指明具体实现）
*   日志文件可以写后，由一个线程执行批量写盘
*   写盘完成后，写盘线程唤醒其余线程，这些线程返回“成功”标识

以下讨论MySQL 5.6中的具体设计

## 几个相关的系统变量

#### sync\_binlog

控制binlog的写盘方式

*   0：MySQL不控制binlog的写盘，由文件系统控制文件缓存区的写盘
*   1：每次事务提交，都会进行一次写
*   N（>1）:每N个事务进行一次写盘

#### innodb\_flush\_log\_at\_trx\_commit

控制redo log的写盘方式

*   0：log buffer每秒写入文件并写入到磁盘
*   1：每次事务提交时，log buffer会写入日志文件，并写入磁盘
*   2：每次事务提交时，log buffer会写入日志文件，每秒一次将日志文件写入到磁盘

#### innodb\_support\_xa

在事务中是否支持两阶段提交协议

*   0：不支持
*   1：支持  
    

## 约束

组提交需要保证如下约束：

*   **【约束1】****binlog和存储引擎具有一致的事务提交顺序******
*   **【约束2】******提交的事务具有持久性********

  

【约束1】基于如下的一些考虑：

*   【考虑1】在事务提交中，推迟存储引擎层的fsync调用，当出现故障后，可以由binlog从特定的点（point）回放来提交丢失的事务（这种场景可能不必须要求一致的提交顺序，但一致的提交顺序是一种简单的实现）
*   【考虑2】使用binlog来进行Slave同步时，一致的事务提交顺序**肯定**能够保证Master/Slave的数据一致性
*   ......

【约束2】是具有事务保障的数据库系统的通用约束，持久性（Durable）是ACID中的“D”，意味着当一个事务成功提交后，即使系统崩溃重启后，依然可以看到事务已经提交

## 实现

让我们看看没有组提交时期的事务提交过程实现

1\.  为了保障【约束1】**持久性**，通常的做法是使用持久化日志的方法，在系统崩溃重启后，通过持久化的日志来恢复崩溃前的状态（持久化的日志还可以用来建立Slave，来提高可用性和可扩展性，例如使用binlog在Slave上进行事务的回放）

在事务执行过程中，对binlog和存储引擎采用阶段提交协议（2 - PC）可以保障事务的原子性、一致性和持久性

 当开启binlog后的两阶段提交流程：

**【两阶段提交】**

*   **Prepare - 1（innobase\_xa\_prepare****）**：事务在存储引擎内持久化，此时的事务依然可以被回滚
*   **Prepare - 2（write and fsync binary log****）**：如果Prepare - 1成功，事务在binlog内持久化
*   **Commit（innobase\_commit）**：事务在存储引擎内提交，即事务不再可以被回滚

可以证明，在以上任意阶段的任意故障，都可以保证事务的：

*   原子性：对于执行失败的事务，回滚或者重新提交
*   一致性：在崩溃恢复时，若binlog和存储引擎崩溃前的状态一直，可以通过回滚或者重新提交保障两者状态的一致性（比如binlog提交成功，而存储引擎提交失败，那么崩溃恢复时，重新再存储引擎提交这个事务）
*   持久性：因为记录事务的日志持久化在磁盘上，因而可以用来进行崩溃恢复

2\.  为了保障【约束2】**一致的事务提交顺序**，在多个事务并发执行的场景下，使用**prepare\_commit\_mutex**。具体如下：

*   在Prepare - 1执行前，获取**prepare\_commit\_mutex**
*   在Commit执行后，释放**prepare\_commit\_mutex**

事务完全串行化执行，前一个事务Commit后下一个事务才能Prepare，并且在两阶段提交时，同时持久化到存储引擎和binlog，必然可以保障一致的提交顺序

这样在Prepare - 2对于binlog的fsync便只能执行当前事务的刷盘，无法实现批量事务的刷盘

注：如果**prepare\_commit\_mutex**提前释放，比如在Prepare - 2阶段释放，那么可能导致：

【例1】

*   事务A获取prepare\_commit\_mutex
*   事务A完成Prepare - 1，Prepare - 2（事务A在binlog内持久化）
*   事务A释放prepare\_commit\_mutex
*   事务B获取prepare\_commit\_mutex
*   事务B完成Prepare - 1，Prepare - 2（事务B在binlog内持久化）
*   事务B释放prepare\_commit\_mutex
*   事务B完成Commit（事务B在存储引擎内持久化）
*   事务A完成Commit（事务A在存储引擎内持久化）

binlog的提交顺序：AB，存储引擎的提交顺序：BA，出现了提交顺序不一致

**【组提交】**

**组提交将Commit过程分成 Flush Stage、Sync Stage、Commit Stage 三个阶段**

每个Stage维护一个队列：

*   如果当一个线程进入到一个空队列时，该线程就做为该队列的 Leader
*   否则该线程均为 Follower  
    
*   Leader带领所有Follower完成该队列的任务，并带领所有Follower进入下一个队列
    *   如果下一个队列非空，Leader降级为Follower
    *   如果下一个队列为空，Leader继续为Leader

通过如下两个方法在保障【约束1】【约束2】的同时，完成binlog的组提交（根据【约束1】的【考虑1】，只需要实现binlog的组提交，redo log则可以异步写盘）

*   **减小锁的粒度：批量事务的binlog刷盘**
*   **队列：在没有全程锁保护的情况下，保障一致的提交顺序**
    
    队列的思想可以这么举例，比如在【例1】中释放prepare\_commit\_mutex后的事务加入Commit队列，防止A先释放锁，却B会先于A进行Commit
    

#### 事务提交阶段

Binlog - **Flush Stage**

*   根据队列顺序将每个线程Binlog Cache中的日志写入MySQL公共Binlog Buffer中（IO\_CACHE log\_file）
*   将MySQL公共Binlog Buffer中的日志写入Binlog日志文件中（内存）

【注意】Leader会在Flush Stage的队列里等待`[binlog_max_flush_queue_time](https://dev.mysql.com/doc/refman/5.6/en/replication-options-binary-log.html#sysvar_binlog_max_flush_queue_time)时长，来保证队列内有一定量的Follower，以"批量化"，但默认binlog_max_flush_queue_time为0，即Leader会一直读取队列中的内容（同时还有THD作为Follower加入）直至队列尾`

Binlog - **Sync Stage**

*   Binlog日志文件（内存）刷入磁盘
    *   sync\_binlog=N时会等待N个组，再将N个组产生的的Binlog刷写入磁盘

InnoDB - **Commit Stage**

*   根据队列顺序调用存储引擎提交事务

其中：

*   Redo Log的写盘时间由**innodb\_flush\_log\_at\_trx\_commit**变量控制
*   Binlog的写盘时间由**sync\_binlog**变量控制

每个队列由Mutex\_queue结构体描述，由成员变量m\_first / m\_last指向队列头 / 尾，由THD->next\_to\_commit来指向队列中下一个元素

![](assets/1591517981-03f01d5576f68fba327558fc9be2eaa8.jpg)

详细过程如下：

```plain
MYSQL_BIN_LOG::ordered_commit()           ← 执行事务顺序提交，binlog group commit的主流程
 |
 |-##################                     ← 进入Stage_manager::FLUSH_STAGE阶段
 |-change_stage(..., &LOCK_log)
 | |-stage_manager.enroll_for()           ← 将当前线程加入到m_queue[FLUSH_STAGE]中
 | |
 | |                                      ← (follower)返回true
 | |-mysql_mutex_lock()                   ← (leader)对LOCK_log加锁，并返回false
 |
 |-finish_commit()                        ← (follower)对于follower则直接返回
 | |-ha_commit_low()
 |
 |-process_flush_stage_queue()            ← (leader)对于follower则直接返回
 | |-fetch_queue_for()                    ← 通过stage_manager获取队列中的成员
 | | |-fetch_and_empty()                  ← 获取元素并清空队列
 | |-ha_flush_log()
 | |-flush_thread_caches()                ← 对于每个线程做该操作
 | |-my_b_tell()                          ← 判断是否超过了max_bin_log_size，如果是则切换binlog文件
 |
 |-flush_cache_to_file()                  ← (follower)将I/O Cache中的内容写到文件中
 |-RUN_HOOK()                             ← 调用HOOK函数，也就是binlog_storage->after_flush()
 |
 |-##################                     ← 进入Stage_manager::SYNC_STAGE阶段
 |-change_stage()
 |-sync_binlog_file()
 | |-mysql_file_sync()
 |   |-my_sync()
 |     |-fdatasync()                      ← 调用系统API写入磁盘，也可以是fsync()
 |
 |-##################                     ← 进入Stage_manager::COMMIT_STAGE阶段
 |-change_stage()                         ← 该阶段会受到binlog_order_commits参数限制
 |-process_commit_stage_queue()           ← 会遍厉所有线程，然后调用如下存储引擎接口
 | |-ha_commit_low()
 |   |-ht->commit()                       ← 调用存储引擎handlerton->commit()
 |   |                                    ← ### 注意，实际调用如下的两个函数
 |   |-binlog_commit()
 |   |-innobase_commit()
 |-process_after_commit_stage_queue()     ← 提交之后的后续处理，例如semisync
 | |-RUN_HOOK()                           ← 调用transaction->after_commit
 |
 |-stage_manager.signal_done()            ← 通知其它线程事务已经提交
 |
 |-finish_commit()
```

## 举例

![](assets/1591517981-270244a62868133e7ceff1dc7949e8f6.png)

**Prepare：**

*   T1先进入Prepare阶段，并完成Prepare阶段，先进入Flush Stage队列，并成为Leader
*   T2随后进入Prepare阶段，随后完成Prepare阶段，进入Flush Stage队列

**Flush Stage：**

*   Flush Stage的Leader（T1）带领所有Followers（T2）进入到Sync Stage队列

**Sync Stage：**

*   Sync Stage为空，T1继续为Leader，T2继续为Follower
*   Leader（T1）带领Follower（T2）进行一次fsync操作，**T1先于T2刷入磁盘**
*   Flush Stage的Leader（T1）带领所有Followers（T2）进入到Commit Stage队列

**Commit Stage：**

*   Commit Stage为空，T1继续为Leader，T2继续为Follower
*   Leader（T1）带领Follower（T2）进行一次存储引擎Commit操作，**T1先于T2在存储引擎内提交**

这里有很关键的一点是：  
将Commit阶段细分解为三个过程后：

*   Flush
*   Sync
*   Commit

细分为这三个过程后，使得事务可以实现部分的并行化（比如T1在Flush时，T2就可以Prepare）

## MySQL 5.7：基于Group Commit的并行复制

能同时进入Prepare队列的事务说明SQL的执行没有锁冲突（SQL语句可以并行执行，T1的SQL语句在执行时，T2的SQL语句也可以在执行时）

*   为这一组事务分配一个相同的last\_commited序号，last\_commited相同表明这组事务在Master上是同时存在于Prepare阶段
*   并按照事务在队列中的顺序分配一个sequence\_number序号，sequence\_number在Master全局递增

具有相同last\_commited序号的事务在Slave上是可以并行复制的（SQL语句的执行没有锁冲突，可以视为“无关联”，比如就是很简单的针对不同表的INSERT操作而已）

## 参考

*   Kristian Nielsen，Fixing MySQL group commit [Part1](http://kristiannielsen.livejournal.com/12254.html)，[Part2](http://kristiannielsen.livejournal.com/12408.html)， [Part3](http://kristiannielsen.livejournal.com/12553.html)， [Part4](http://kristiannielsen.livejournal.com/12810.html)  
    
*   [MariaDB WL#116](http://worklog.askmonty.org/worklog/Server-Sprint/?tid=116)
*   [MySQL 组提交](https://jin-yang.github.io/post/mysql-group-commit.html)  
    
*   [MySQL Bug #13669](https://bugs.mysql.com/bug.php?id=13669)
*   [MySQL并发复制系列三：MySQL和MariaDB实现对比](http://blog.itpub.net/28218939/viewspace-1975856/)
*   [MySQL并发复制系列（一）｜binlog组提交](http://blog.woqutech.com/2018/02/27/mysql%E5%B9%B6%E5%8F%91%E5%A4%8D%E5%88%B6%E7%B3%BB%E5%88%97%EF%BC%88%E4%B8%80%EF%BC%89%EF%BD%9Cbinlog%E7%BB%84%E6%8F%90%E4%BA%A4/)
*   [Binary Log Group Commit in MySQL 5.6 (IMPORTANT!)](http://mysqlmusings.blogspot.com/2012/06/binary-log-group-commit-in-mysql-56.html)



