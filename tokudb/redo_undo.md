#<center>redo</center>

#一.redo-log

记录的不是页而是对Fractal-Tree索引的操作日志。 log格式:

> | length | command | lsn | content | crc|

content里记录的是具体的日志内容，比如insert操作，content就是:

> | file-no | txnid | key | value|


TokuDB在做恢复的时候，会找到上次checkpoint时的LSN位置，然后读取log逐条恢复。

为了确保log的安全性，redo-log也支持从后往前解析。

当一个log的MAX_LSN小于已完成checkpoint的LSN时，就表明这个log文件可以安全删除了。

那么问题来了：

如果用户执行了一个“大事务”，比如delete一个大表，耗时很长，log文件岂不是非常多，一直等到事务提交再做清理？

不用的，这就是tokudb.rollback的作用了。


##1.1. toku_log_enq_insert

```cpp
caller:
--ft_txn_log_insert
``` 

##1.2. ft\_txn\_log_insert

```cpp
caller:
--toku_ft_insert_unique
--toku_ft_maybe_insert
```

##1.3.db_put

```cpp
caller:
do_put_multiple
toku_db_put


toku_db_put
--db_put
----toku_ft_insert_unique
----toku_ft_maybe_insert
```

##1.4. toku_db_put

```cpp
caller:
--autotxn_db_put
--toku_db_open
--load_inames
--env_dbrename
--env_dirtool_move
--env_dirtool_attach
--env_open
--maybe_upgrade_persistent_environment_dictionary
```

#5. autotxn_db_put

```
caller:
--toku_db_create
```

#二、tokudb.rollback

用户的事务操作(insert/delete/update写操作)都会写一条日志到tokudb.rollback，存储的格式是:

|txnid | key|
记录日志伪码如下：

```cpp
void ft_insert(txn,...)
{
   if (txn) {
       toku_logger_save_rollback_cmdinsert(...);
   }

   if (do_logging && logger) {
       toku_log_enq_insert(....);
   }
}
```
如果是事务，每个操作会写2条日志(1条redo，1条rollback)。

如果用户执行了commit/rollback，TokuDB会根据txnid在tokudb.rollback里查到key(如果该entry不在cache里)，再根据key在索引文件里找到相应的事务信息并做相应的commit/rollback操作。

tokudb.rollback可以看做是一个事务的undo日志，记录的是的关系映射。

##2.1.toku_logger_save_rollback_cmdinsert

```
caller:
--ft_txn_log_insert
```