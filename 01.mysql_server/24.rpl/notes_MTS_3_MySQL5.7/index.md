
# [MySQL 5.7：并行复制]

MySQL 5.7的并行复制在组提交的基础上设计的，策略就是：

*   在Master上的并行事务，在Slave上就可以并行回放

在组提交时（ordered\_commit），进入Flush Stage的队列中的THD如图

![](assets/1591577450-589dab5d60a99de05bc5548497bfe0a5.jpg)

其中：

*   last\_committed标识为同一队列中
*   sequence\_number标识同一队列中的先后顺序
    

MySQL 5.7里为每一个事务在Server层新增一个Transaction\_ctx对象表示

```plain
class Transaction_ctx
{
    ...
    /* storage engines that registered in this transaction */
    Ha_trx_info *m_ha_list;
     
    /* Binlog-specific logical timestamps. */
    int64 last_committed;
    int64 sequence_number;
    ...
}
```

#### last\_committed

在语句提交时（参考[MySQL 5.6：事务模型]）

【Binlog Prepare】binlog\_prepare修改为

```plain
static int binlog_prepare(handlerton *hton, THD *thd, bool all)
{
    ...
+   if (!all) // 语句提交时all是FALSE，用户提交（或者DDL产生的隐式提交）时all是TRUE
+   {
+     Logical_clock& clock= mysql_bin_log.max_committed_transaction;
+     thd->get_transaction()->
+       store_commit_parent(clock.get_timestamp());
+   }
    ...
}
```

#### sequence\_number

在组提交的Flush Stage中赋值

```plain
 |- ordered_commit
    |- process_flush_stage_queue // 将每个线程产生的Binlog日志刷入公共Binlog Buffer
        |- flush_thread_caches // 线程设置私有的sequence_number
    |- flush_cache_to_file // 将公共Binlog Buffer刷入日志文件（内存）中，在Sync Stage中会将日志文件（内存）刷写入磁盘
```

#### last\_committed / sequence\_number的关系

1.  全局变量last\_committed初始化为1
2.  一些事务（比如三个事务T1、T2、T3）在Prepare阶段获得了last\_committed=1，并且sequence\_number(T1)=1，sequence\_number(T2)=2，sequence\_number(T3)=3
3.  这三个事务组提交成功，更新last\_committed=3
4.  一些事务（比如T4、T5）在在Prepare阶段获得了last\_committed=3，并且sequence\_number(T1)=4，sequence\_number(T2)=5
5.  这两个事务组提交成功，更新last\_committed=5
6.  ...

last\_committed是组提交的计数

sequence\_number是已经提交的事务的计数

#### Slave上如何回放？

两个命题：

*   【命题1】具有相同last\_committed的事务**肯定**是并发事务
*   【命题2】具有不同last\_committed的事务**可能**是并发事务

首先，max\_committed\_transaction是在Commit Stage进行更新的，而且是**无锁保护的更新**

```plain
MYSQL_BIN_LOG::process_commit_stage_queue(THD *thd, THD *first)
{
    ...
    for (THD *head= first ; head ; head = head->next_to_commit)
    {
        if (thd->get_transaction()->sequence_number != SEQ_UNINIT)
            update_max_committed(head);
    }
}
```

【命题1证明】

假设两个事物T1、T2具有相同的last\_committed=1，但不是并发事务，即一个事务的结束时间早于另一个事务的开始时间，另End\_Time(T1) > Start\_Time(T2)

那么：

1.  T1在结束前需要更新max\_committed\_transaction，max\_committed\_transaction > last\_committe(T1) = 1
2.  T2在开始后需要获取last\_committed，但max\_committed\_transaction > 1，因此last\_committe(T2)不可能为1，矛盾

所以，具有相同last\_committed的事务在Master上是并发事务，那么在Slave上也可以是并发事务（即并行回放）

【命题2证明】

考虑如下场景：

1.  队列共有三个事务T1（Leader）、T2、T3刚刚进入Commit Stage，last\_committed都为1
2.  事务T4在Prepare阶段获得**last\_committed(T4)=1**
3.  事务T1提交，更新max\_committed\_transaction=2
4.  事务T5在Prepare阶段获得**last\_committed(T4)=2**

那么，T4、T5是并发事务但具有不同的last\_committed。这是此种并行复制策略下的一个待优化点，T4、T5是并发事务但在Slave上没有并行回放。也就是说，我们希望并发事务几乎都具有相同的last\_committed，构成命题3

*   【命题3】并发事务几乎都具有相同的last\_committed

为了使【命题3】的概率很大，实现上就是：

*   在事务刚一开始就获取last\_committed（与事务开始时间越接近越好）：在binlog\_prepare，就获取last\_committed
*   在事务即将结束才更新max\_committed\_transaction（与事务结束时间越接近越好）：在Commit Stage，才更新max\_committed\_transaction

在Master上其实还有一个隐藏的设定，事务都存在于一个线程中，我们肯定是在客户端连接到MySQL后，输入类似下面的一连串命令：

```sql
-- 一个事务
BEGIN;
INSERT INTO t1 VALUES ...
DELETE FROM t2 SET ...
COMMIT;
```

这个事务中的所有SQL语句肯定是由一个线程接收到，那么在Slave上也会这样？

因为在Flush Stage时，每个线程将私有的Binlog日志提交到公共Binlog Buffer中，因此在Binlog日志文件中，事务的记录是_**连续的**_

```plain
#180411 15:01:34 server id 1026872635  end_log_pos 1137 CRC32 0x34a7ce63        Anonymous_GTID  last_committed=4        sequence_number=5
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 1137
#180411 15:00:59 server id 1026872635  end_log_pos 1216 CRC32 0x39f617d9        Query   thread_id=5     exec_time=0     error_code=0
SET TIMESTAMP=1523430059/*!*/;
BEGIN
/*!*/;
# at 1216
#180411 15:00:59 server id 1026872635  end_log_pos 1322 CRC32 0x43f1450b        Query   thread_id=5     exec_time=0     error_code=0
SET TIMESTAMP=1523430059/*!*/;
insert into t1 values (3, 'Mary')
/*!*/;
# at 1322
#180411 15:01:32 server id 1026872635  end_log_pos 1428 CRC32 0x08161142        Query   thread_id=5     exec_time=0     error_code=0
SET TIMESTAMP=1523430092/*!*/;
insert into t2 values (4, 'Peter')
/*!*/;
# at 1428
#180411 15:01:34 server id 1026872635  end_log_pos 1459 CRC32 0xe3883a23        Xid = 42
COMMIT/*!*/;
```
