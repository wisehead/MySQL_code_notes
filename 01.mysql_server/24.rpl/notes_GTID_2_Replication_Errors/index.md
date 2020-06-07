

# [GTID（二）：集群中的数据同步]

### 背景

在One Master / Multi Slaves的场景下，

对于Master/Slave的binlog存在如下四种情况：

【1】Master binlog单方面增加

【2】Master binlog单方面删除

【3】Slave binlog单方面增加

【4】Slave binlog单方面删除

对于复制的binlog执行过程，还存在两种情况：

【5】事务执行成功

【6】事务执行失败，原因可能是：

*   Master/Slave初始数据不一致，相同的事务在Slave上执行报错

其中：

*   对于【1】：Slave通过常规复制完成数据同步
*   **对于【2】**：【ERROR 1263】Got fatal error 1236 from master when reading data from binary log: ' The slave is connecting using CHANGE MASTER TO MASTER\_AUTO\_POSITION = 1, but the master has purged binary logs containing GTIDs that the slave requires. '
*   **对于【3】**：**Errant Transaction**
*   对于【4】：常规binlog删除操作
*   对于【5】：执行成功
*   **对于【6】**：报错的依赖于具体的SQL语句

以下重点讨论【2】【3】【6】

### 情况2：ERROR 1263

Master单方面删除binlog是指：

*   Master删除了一部分binlog
*   Slave还没有复制这部分binlog
*   Slave请求这部分binlog，报错

  

【例如】

```plain
1. 人工暂停SLAVE进程；
2. MASTER上继续写入数据，产生新的BINLOG_1和BINLOG_2
4. MASTER上删除旧BINLOG_1，只保留BINLOG_2；
5. SLAVE上启动MASTER，这时候会报错，像下面这样：
Last_IO_Errno: 1236
Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'The slave is connecting using CHANGE MASTER TO MASTER_AUTO_POSITION = 1, but the master has purged binary logs containing GTIDs that the slave requires.'
```

【分析】

```plain
-- rpl_master.cc
/*
    Setting GTID_PURGED (when GTID_EXECUTED set is empty i.e., when
    previous_gtids are also empty) will make binlog rotate. That
    leaves first binary log with empty previous_gtids and second
    binary log's previous_gtids with the value of gtid_purged.
    In find_first_log_not_in_gtid_set() while we search for a binary
    log whose previous_gtid_set is subset of slave_gtid_executed,
    in this particular case, server will always find the first binary
    log with empty previous_gtids which is subset of any given
    slave_gtid_executed. Thus Master thinks that it found the first
    binary log which is actually not correct and unable to catch
    this error situation. Hence adding below extra if condition
    to check the situation. Slave should know about Master's purged GTIDs.
    If Slave's GTID executed + retrieved set does not contain Master's
    complete purged GTID list, that means Slave is requesting(expecting)
    GTIDs which were purged by Master. We should let Slave know about the
    situation. i.e., throw error if slave's GTID executed set is not
    a superset of Master's purged GTID set.
    The other case, where user deleted binary logs manually
    (without using 'PURGE BINARY LOGS' command) but gtid_purged
    is not set by the user, the following if condition cannot catch it.
    But that is not a problem because in find_first_log_not_in_gtid_set()
    while checking for subset previous_gtids binary log, the logic
    will not find one and an error ER_MASTER_HAS_PURGED_REQUIRED_GTIDS
    is thrown from there.
*/
if (!gtid_state->get_lost_gtids()->is_subset(slave_gtid_executed))
{
    errmsg= ER(ER_MASTER_HAS_PURGED_REQUIRED_GTIDS);
    my_errno= ER_MASTER_FATAL_ERROR_READING_BINLOG;
    global_sid_lock->unlock();
    GOTO_ERR;
}
```

从注释中可以看出，产生这个错误的原因是Master的lost\_gitds不是slave\_gtid\_executed的子集，也就是Master删除了Slave没有执行的GTIDs

【解决方法1】FILE & POS

*   STOP SLAVE
*   CHANGE MASTER TO ... FILE & POS , MASTER\_AUTO\_POSITION = 0
*   START SLAVE

当START SLAVE、正常数据同步后，很可能会产生**GTID空洞，**见[GTID（三）：不连续的GTID]

【解决方法2】重置GTID\_PURGED

\-- Master

*   select @@gtid\_purged;

```sql
+-------------------------------------------+
| @@gtid_purged                             |
+-------------------------------------------+
| master_uuid:start-end                     |
+-------------------------------------------+
```

\-- Slave

*   STOP SLAVE
*   RESET MASTER
*   SET GLOBAL GTID\_PURGED='master\_uuid:start-end'
*   START SLAVE

思想为重置slave\_gtid\_executed=Master lost\_gitds：

*   因为gtid\_executed为只读变量，无法直接设置
*   但当gtid\_executed为空时，可以通过设置gtid\_purged来设置gtid\_executed
*   RESET MASTER可以使gtid\_executed为空

【注意】此时的Slave不会再执行Master上的GTID在master\_uuid:start-end中的事务了，要保证所有数据均已同步，可以采用【解决方法1】来保证，然后再使用【解决方法2】来再次启用GTID复制模式

源码如下：

```plain
-- syatem_vars.h
bool global_update(THD *thd, set_var *var)
{
    ...
    char *previous_gtid_logged= gtid_state->get_logged_gtids()->to_string();
    char *previous_gtid_lost= gtid_state->get_lost_gtids()->to_string();
    // 会同时更新lost_gtids和logged_gtids
    enum_return_status ret= gtid_state->add_lost_gtids(var->save_result.string_value.str);
    char *current_gtid_logged= gtid_state->get_logged_gtids()->to_string();
    char *current_gtid_lost= gtid_state->get_lost_gtids()->to_string();
    ...
  }
```

```plain
-- rpl_gtid_state.cc
enum_return_status Gtid_state::add_lost_gtids(const char *text)
{
  DBUG_ENTER("Gtid_state::add_lost_gtids()");
  sid_lock->assert_some_wrlock();
  DBUG_PRINT("info", ("add_lost_gtids '%s'", text));
  // logged_gtids必须为空
  if (!logged_gtids.is_empty())
  {
    BINLOG_ERROR((ER(ER_CANT_SET_GTID_PURGED_WHEN_GTID_EXECUTED_IS_NOT_EMPTY)),
                 (ER_CANT_SET_GTID_PURGED_WHEN_GTID_EXECUTED_IS_NOT_EMPTY,
                 MYF(0)));
    RETURN_REPORTED_ERROR;
  }
  // owned_gtids必须为空
  if (!owned_gtids.is_empty())
  {
    BINLOG_ERROR((ER(ER_CANT_SET_GTID_PURGED_WHEN_OWNED_GTIDS_IS_NOT_EMPTY)),
                 (ER_CANT_SET_GTID_PURGED_WHEN_OWNED_GTIDS_IS_NOT_EMPTY,
                 MYF(0)));
    RETURN_REPORTED_ERROR;
  }
  DBUG_ASSERT(lost_gtids.is_empty());
  //既更新lost_gtids，又更新logged_gtids，为了保证lost_gtids必须是logged_gtids的子集
  PROPAGATE_REPORTED_ERROR(lost_gtids.add_gtid_text(text));
  PROPAGATE_REPORTED_ERROR(logged_gtids.add_gtid_text(text));
  DBUG_RETURN(RETURN_STATUS_OK);
}
```

### 情况3：**Errant Transaction**

【可能原因1】Slave违规写入

正常的，单独在Slave写入违反Master/Slave结构的模式（Write-To-Master，Read-From-Slave）

如果发生单独在Slave写入事务，该事务称为Errant Transaction，在Slave升级为Master后可能导致Errant Transaction传递下去，考虑如下场景：

*   Node1为Master，Node2为Slave，在GTID模式下，Node2执行了一个Errant Transaction，记作T1
*   Node1崩溃后，Node2变为新的Master，Node3为新的Slave
*   Node3会从Node2复制T1，并执行T1
*   Errant Transaction并不是客户端/用户执行的事务（客户端/用户执行的事务都由Node1执行，并传递给Node2等所有的Slave）

此时需要跳过这个Errant Transaction，设Errant Transaction的GTID为ET\_GTID

如果需要在Slave上写入，建议SET SQL\_LOG\_BIN=0（事务不写入binlog）

【可能原因2】Master Crash

MySQL 5.6中Master上的事务在提交时，事务被写入binlog并将binlog刷盘，并同时发送给Slave，写入binlog和发给Slave同时进行. Master在将binlog刷盘后，将事务提交（Commit）到InnoDB，然后开始

等待Slave的ACK，在收到Slave的ACK之后，然后将结果返回到提交事务的Client，那么如果Master Commit InnoDB失败，而Slave上已经提交，会导致Slave上比Master有更多的GTIDs

【解决方法1】空事务

在Slave上执行序号为ET\_GTID的**空事务，**这样Slave就不会再执行Master复制过来的相同序号的Errant Transaction

*   STOP SLAVE
*   SET GTID\_NEXT='ET\_GTID'
*   BEGIN;COMMIT;
*   SET GTID\_NEXT="AUTOMATIC";
*   START SLAVE;

【解决方法2】重置GTID\_PURGED

同【情况2】的【解决方法2】重置GTID\_PURGED

### 情况6：事务执行报错

由于数据为完全同步的原因思想为在Slave上跳过报错的事务，设报错的事务GTID为Err\_GTID

【解决方法】空事务

同【情况3】的【解决方法1】空事务

