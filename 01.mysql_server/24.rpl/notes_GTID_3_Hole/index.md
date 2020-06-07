

# [GTID（三）：不连续的GTID]

这里我们来分析什么场景可能会出现**不连续的GTID**

## 并行复制

并行复制的事务处于并行执行状态，GTID集合（Executed\_Gtid\_Set）出现空洞是正常现象，并且在并行复制完成后会最终一致

## 人为修改GTID\_NEXT

人工的指定GTID\_NEXT为具体值时（**SET GTID\_NEXT='<some\_value>'**），在Executed\_Gtid\_Set尾部可能导致正常的GTID空洞

```sql
+------------------+----------+--------------+------------------+----------------------------------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                            |
+------------------+----------+--------------+------------------+----------------------------------------------+
| mysql-bin.000010 |     1566 |              |                  | d9dd8550-1f4c-11e7-a44b-cbca9484dbbd:1-12:15 |
+------------------+----------+--------------+------------------+----------------------------------------------+
```

重新执行**SET GTID\_NEXT='AUTOMATIC';**后，MySQL会分配一个最小的未使用的GTID，此处就是d9dd8550-1f4c-11e7-a44b-cbca9484dbbd:11，这种情况不需要修复

所以，严格来讲同一个具有server-uuid下的GTID的大小不严格代表了事务执行的先后关系，要以记录到binlog的先后顺序为准

比如：

*   gtid\_executed = uuid:1-10
*   SET GTID\_NEXT = uuid:15
*   执行事务T1（uuid:15）
*   SET GTID\_NEXT = AUTOMATIC
*   执行事务T2（uuid:11）
*   那么，T1的GTID大于T2，但T1早于T2执行

## FILE & POS的故障修复

在[GTID（二）：集群中的数据同步]中的【情况2】->【解决方法1】中已详细说明，由于Master删除了部分Slave还没有同步的数据（GTIDs），导致START SLAVE后报错

```plain
Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'The slave is connecting using CHANGE MASTER TO MASTER_AUTO_POSITION = 1, but the master has purged binary logs containing GTIDs that the slave requires.'
```

【解决方法1】使用传统复制方法来解决，CHANGE MASTER TO ... FILE & POS

那么，例如：

Master / Slave数据已同步

\-- Slave

*   **STOP SLAVE**
*   Slave gtid\_executed = master\_uuid: 1 - 10

\-- Master

*   当前binlog为master-bin.000005
*   执行一些事务 ... 
*   Master gtid\_executed = master\_uuid: 1 - 20
*   然后binlog为master-bin.000007
*   **PURGE BINARY LOGS TO** 'master-bin.000007'（比如master-bin.000007中的GTIDs为master\_uuid: 16 - 20）
*   此时删除的master-bin.000006包含的全部是Slave没有执行的事务
*   Master gtid\_purged = master\_uuid：1 - 15

\-- Slave 

*   **START SLAVE**
*   **SHOW SLAVE STATUS\\G**，报错ERROR 1236
*   【原因】Master gtid\_purged不是Slave gtid\_executed的子集了（在[GTID（二）：集群中的数据同步]中由详细说明）

\-- Master

*   **SHOW MASTER STATUS**：File = master-bin.000007, Pos = 100

\-- Slave

*   **CHANGE MASTER TO, MASTER\_LOG\_FILE='master-bin.000007', MASTER\_LOG\_POS=100;**
*   Slave便会从下一个新的事务（master\_uuid: 21）开始复制了
*   Slave gtid\_executed = master\_uuid: 1 - 10，21 - ...  
    

## Xtrabackup 备份的恢复

（未完待续）

## 参考

*   [Mysql 5.7 Gtid内部学习(五) mysql.gtid\_executed表/gtid\_executed变量/gtid\_purged变量的更改时机](https://yq.aliyun.com/articles/294004)  


