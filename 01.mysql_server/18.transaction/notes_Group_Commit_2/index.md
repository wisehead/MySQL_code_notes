

# [MySQL 5.6：Binlog Group Commit（二）]

根据[MySQL 5.6：事务模型]，我们知道一个事务的执行分为三个阶段：事务开始 / 事务执行 / 事务提交，符合于**二阶段提交**

## MySQL 5.5

在MySQL 5.6以前，通过臭名昭著的prepare\_commit\_mutex锁来实现**Binlog中事务的记录顺序**和**事务的提交顺序**是一致的，每次只能fsync一个事务的Binlog

*   获取prepare\_commit\_mutex
*   InnoDB Prepare
*   Binlog Prepare (write and fsync binary log)
*   InnoDB Commit (Binlog Commit什么都不做)
*   释放prepare\_commit\_mutex

因为：

1.  fsync的代价昂贵，磁盘每秒执行fsync的次数存在上限
2.  每次fsync的数据量对fsync的耗时影响达不到线程增长

## MySQL 5.6

MySQL 5.6中，去掉了prepare\_commit\_mutex，使用Group Commit的方式每次fsync“批量”事务的Binlog，Binlog和Redo日志记录的事务顺序一致的保证也在下文讨论

参考[MySQL 5.6：Binlog Group Commit]

Group Commit发生在【事务提交阶段】

Binlog - **Flush Stage**

*   Leader线程根据Flush队列顺序将每个线程Binlog Cache中的日志写入MySQL公共Binlog Buffer中（IO\_CACHE log\_file）
*   将MySQL公共Binlog Buffer中的日志写入Binlog日志文件中（内存）

Binlog - **Sync Stage**

*   Flush队列的线程按顺序进入到Sync队列
*   Leader线程将Binlog日志文件（内存）刷入磁盘

InnoDB - **Commit Stage**

*   Sync队列的线程按顺序进入到Commit队列  
    
*   Leader根据Commit队列顺序调用存储引擎提交每个线程的事务

注：当前活跃线程是Leader，Follower线程全部休眠

### 顺序一致性

那么，这里为什么要使用队列，使用集合表示一个“事务组”可以吗？

Flush / Sync / Commit队列里的线程具有相同的顺序是为了保证：

*   Binlog中事务的记录顺序和事务的提交顺序是一致的

但目前已证明这**无关紧要**

在参考【3】中指出这个顺序一致性的原因

```plain
Since these on-line backup methods are often used to bootstrap new slaves, the binary log position of the
last committed transaction is written in the header of the InnoDB redo log. On recovery, the recovery pr-
ogram print the binary log position of the last committed transaction and you can use this information with
the CHANGE MASTER command to start replicating from the correct position. For this to work correctly, it is
necessary that all the transactions are committed in the same order as they are written to the binary log. 
If they are not there can be "holes" where some transactions are written to the binary log, but not yet com-
mitted, which cause the slave to miss transactions that were not committed.
```

在InnoDB Commit时（innobase\_commit），会将该事务的Binlog提交到到公共的Cache中（Flush Stage），将当时（文件名 / 偏移量）写入到InnoDB系统表空间中的TRX\_SYS\_MYSQL\_LOG\_INFO

```plain
/*****************************************************************//**
Commits a transaction in an InnoDB database or marks an SQL statement
ended.
@return 0 */
static
int
innobase_commit
{
  /* The following call read the binary log position of
    the transaction being committed.
 
    Binary logging of other engines is not relevant to
    InnoDB as all InnoDB requires is that committing
    InnoDB transactions appear in the same order in the
    MySQL binary log as they appear in InnoDB logs, which
    is guaranteed by the server.
 
    If the binary log is not enabled, or the transaction
    is not written to the binary log, the file name will
    be a NULL pointer. */
    
  unsigned long long pos;
  thd_binlog_pos(thd, &trx->mysql_log_file_name, &pos);
  trx->mysql_log_offset= static_cast<ib_int64_t>(pos);
  ...
}
```

而如果  InnoDB的热备份工具依赖于 TRX\_SYS\_MYSQL\_LOG\_INFO 来确定与备份对齐的Binlog位置便会出错（而对于像 Xtrabackup 不依赖于 TRX\_SYS\_MYSQL\_LOG\_INFO 则不会出错），那么比如：

*   Binlog中的顺序：T1（50），T2（100）
*   InnoDB提交的顺序：T2，T1。
*   （Xtrabackup备份结束）

会导致TRX\_SYS\_MYSQL\_LOG\_INFO被T1的覆盖（50）

那么当使用此备份建立Slave后，CHANGE MASTER TO ... 50，会导致T2的重复执行

_**因此，这个顺序一致只对于部分备份工具有影响，而对 Xtrabackup 却无影响**_

#### Group Commit的作用

1\. 减少事务的平均执行时间

这里一定要注意，Group Commit增加了每个事务的执行时间，但减小了所有事务的平均执行时间

![](assets/1591520879-225134dbf210ea4433225118401721e5.png)

【错误观点】

MySQL 5.5（Group Commit之前），一个事务的耗时 = 事务执行时间 + fsync(Binlog) + fsync(Redo)

MySQL 5.5之后（Group Commit），一个事务的耗时 = 事务执行时间 + fsync(Binlog) / N + fsync(Redo)

但其实Group Commit队列中的每一个事务：

*   首先会等待队列为满
*   再会等待Leader执行完Flush / Sync / Commit三个阶段后才会被唤醒（这部分时间与MySQL 5.5中一个事务的耗时相同）

所以，每个事务的耗时都增加了，但因为“时间叠加”的原因，导致平均耗时缩短

2\. 降低“写放大”问题

磁盘的写入单元是扇区（机械磁盘是512K，SSD是4M），无论一次写入数据量多少都会与扇区“对齐”，比如想写入10B，但也需要写入512K，这就是“写放大”问题

因此一次fsync的数据量越多，更能降低“写放大”问题

## InnoDB的Group Commit 

或者说，Redo日志有没有Group Commit的效用，即可以一次fsync“批量”事务的Redo日志 ?

### Binlog开启时

**MySQL 5.7.6之前**

根据[MySQL 5.6：事务模型]，Redo日志的刷盘在【InnoDB Prepare】阶段中，即每个事务都会将自身产生的Redo日志刷写到磁盘中

![](assets/1591520879-e56d08e1bcb2cb56e1c5a4f9aa96d3f6.png)

#### MySQL 5.7.6之后

进行了InnoDB Group Commit的设计：

*   在Flush Stage阶段，在每个线程产生的Binlog刷入磁盘前，Leader将当前公共Redo Buffer的内容“批量”写入磁盘

![](assets/1591520879-c4d56528e64f5633df3c1d3a736f7de9.png)

注意，在现有的InnoDB Crash Recovery逻辑下，_**Redo日志的落盘一定要早于Binlog**_

设想，如果Redo日志的落盘晚于Binlog，那么可能会出现这样的情况：在Binlog中找到事务T的xid，但T的Redo日志没有完全落盘，因此InnoDB无法提交事务T（目前的InnoDB Crash Recovery逻辑，InnoDB需要提交事务T）

#### 正确性

这里需要保证队列中所有的线程产生的Redo日志都被写入磁盘（因为接下来的Commit Stage中所有线程都被标记为已提交），在公共Redo Buffer中刷写到的位置是log\_sys->lsn

 log\_sys->lsn是在【事务执行阶段】，一个MTR执行结束（mtr的commit）将私有的Redo日志写入到公共Redo Buffer中，会更新log\_sys->lsn

在组提交的Flush Stage中，已进入【事务提交阶段】，即每个在Flush Stage阶段的事务产生的Redo日志已写入公共Redo Buffer，所以log\_sys->lsn已经包含每个处于Flush Stage阶段的事务

```plain
int
MYSQL_BIN_LOG::process_flush_stage_queue(my_off_t *total_bytes_var,
                                         bool *rotate_var,
                                         THD **out_queue_var)
{
  // InnoDB：将Redo日志从公共Log Buffer写入磁盘文件中
  ha_flush_logs(NULL, true);
  
  for (THD *head= first_seen ; head ; head = head->next_to_commit)
  {
    // 当前的线程是Leader，取出每个THD，将每个THD内存储的Binlog内容写入公共Binlog Buffer内
    std::pair<int,my_off_t> result= flush_thread_caches(head);
    ...
  }
  ...
}
```

### Binlog关闭时

Binlog关闭后，TC\_LOG（Transcation Coordinator Log）是TC\_LOG\_DUMMY

```plain
// 有两个及以上的事务型存储引擎 或者 有一个事务型引擎同时开启了Binlog
if (total_ha_2pc > 1 || (1 == total_ha_2pc && opt_bin_log))
{
  if (opt_bin_log)
    tc_log= &mysql_bin_log;
  else
    tc_log= &tc_log_mmap;
}
// 有一个事务型存储引擎并且关闭了Binlog
else
  tc_log= &tc_log_dummy;
  
// TC_LOG_DUMMY的实现
class TC_LOG_DUMMY: public TC_LOG // use it to disable the logging
{
public:
  TC_LOG_DUMMY() {}
  int open(const char *opt_name)        { return 0; }
  void close()                          { }
  enum_result commit(THD *thd, bool all) {
    return ha_commit_low(thd, all) ? RESULT_ABORTED : RESULT_SUCCESS;
  }
  int rollback(THD *thd, bool all) {
    return ha_rollback_low(thd, all);
  }
  int prepare(THD *thd, bool all) {
    return ha_prepare_low(thd, all);
  }
};
```

Binlog关闭后，事务的提交不再是两阶段

```plain
int ha_commit_trans(THD *thd, bool all, bool ignore_global_read_lock)
{
  if (ha_info)
  {
    if (!trans->no_2pc && (rw_ha_count > 1)) // 关闭Binlog后，rw_ha_count（读写插件数目）为1
      error= tc_log->prepare(thd, all); // Prepare阶段
  }
  
  if (error || (error= tc_log->commit(thd, all))) // Commit阶段,比如只有InnoDB（即调用innobase_commit）
  {
    ha_rollback_trans(thd, all); // 若提交失败则回滚
    error= 1;
    goto end;
  }
}
```

innobase\_commit主要为以下两步：

*   innobase\_commit\_low(trx)：内存操作（设置事务状态为TRX\_STATE\_COMMITTED\_IN\_MEMORY，这里**违反了WAL**），由MTR产生LSN，传入trx\_commit\_complete\_for\_mysql写盘时使用  
    
*   trx\_commit\_complete\_for\_mysql(trx)：磁盘操作（将此次提交产生的Redo日志写入磁盘）

在一些场景下可能会产生“批量”写盘

*   Trx1 - innobase\_commit\_low：产生LSN1
*   Trx2 - innobase\_commit\_low：产生LSN2（LSN2 > LSN1）
*   Trx2 - trx\_commit\_complete\_for\_mysql：顺带将Trx1的Redo日志刷入磁盘
*   Trx1 - trx\_commit\_complete\_for\_mysql：发生Redo日志已刷入磁盘，什么都不做

需要注意的是innobase\_commit违反了WAL规则，在lock\_trx\_release\_locks函数中：

```plain
/* The following assignment makes the transaction committed in memory
    and makes its changes to data visible to other transactions.
    NOTE that there is a small discrepancy from the strict formal
    visibility rules here: a human user of the database can see
    modifications made by another transaction T even before the necessary
    log segment has been flushed to the disk. If the database happens to
    crash before the flush, the user has seen modifications from T which
    will never be a committed transaction. However, any transaction T2
    which sees the modifications of the committing transaction T, and
    which also itself makes modifications to the database, will get an lsn
    larger than the committing transaction T. In the case where the log
    flush fails, and T never gets committed, also T2 will never get
    committed. */
trx->state = TRX_STATE_COMMITTED_IN_MEMORY;
```

因为ordered\_commit是在MYSQL\_BIN\_LOG::commit里调用，考虑可以将ordered\_commit的部分逻辑移植到TC\_LOG\_DUMMY->commit中

## 参考

1.  [InnoDB---深入理解事务提交–01](http://blog.163.com/li_hx/blog/static/1839914132016112991511518)
2.  [Efficient group commit for binary log](http://worklog.askmonty.org/worklog/Server-Sprint/?tid=116)
3.  [Binary Log Group Commit in MySQL 5.6 (IMPORTANT!)](http://mysqlmusings.blogspot.com/2012/06/binary-log-group-commit-in-mysql-56.html)



