#1.trans_commit

事务提交
COMMIT;
* 【Binlog Prepare】binlog_prepare：什么都不做
* 【InnoDB Prepare】innobase_xa_prepare：
	* 【1】将事务状态置为PREPARED
	* 【2】将Redo日志写入磁盘
* 【Commit】
	* 【0】在Binlog中产生Xid_log_event
	* 【1】Flush Stage：   将Binlog内容写入Binlog日志文件（操作系统的Page Cache中，尚未落盘）
	* 【2】Sync Stage：    将Binlog文件落盘
	* 【3】Commit Stage：存储引擎提交（此处以InnoDB为例）
	*   注意：以下所有动作产生的Redo日志在一个MTR内（MTR能保证其包含的所有日志如果只有部分落盘, 在Crash Recovery时会被丢弃）
		* 清理insert_undo日志
		* 将update_undo日志加入回滚段的History-List（Purge线程定期清理）
		* 释放事务持有的所有锁（比如，修改同一行记录的事务需要有互斥锁）
		* 清理（如果有的话）Savepoint列表
		* 内存中事务结构体的状态置为COMMITTED（准确的是TRX_STATE_COMMITTED_IN_MEMORY）
		* Undo日志中事务的状态TRX_UNDO_CACHED / TRX_UNDO_TO_FREE / TRX_UNDO_TO_PURGE（在Crash Recovery时，读到这三种状态都会将事务内存结构置为TRX_STATE_COMMITTED_IN_MEMORY）

```cpp
--- 代码调用路径
mysql_execute_command
  |-trans_commit
    |-ha_commit_trans // MySQL Server和存储引擎做两阶段提交
      |-MYSQL_BIN_LOG::prepare(tc_log->prepare) // TC_LOG就是Transaction Coordinator Log，MYSQL_BIN_LOG是TC_LOG的一个继承类
      // 以下是因为Binlog的使用，导致Binlog和存储引擎必须做的二阶段提交，MMAP_LOG没有Prepare阶段
        |-ha_prepare_low
          |-binlog_prepare
          |-innobase_xa_prepare
      |-MYSQL_BIN_LOG::commit(tc_log->commit)
        |-ordered_commit:
          |-Flush Stage
          |-Sync Stage
          |-Commit Stage
          |-finish_commit
        |-ha_commit_low
          |-binlog_commit
          |-innobase_commit
```