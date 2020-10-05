

# [MySQL 5.6：Slave Crash Safe]

## 问题

在Master-Slave均使用TokuDB复制下：

1.  Slave仍在同步数据时异常Crash（例如外界执行kill -9 <slave\_pid>）
2.  Slave重启后执行START SLAVE，会有丢数据的可能性

【例】

*   Slave上的表test ，CREATE TABLE test (c varchar(20), PRIMARY KEY(c))
*   kill -9 <slave\_pid>
*   假设Slave此时在执行INSERT INTO t VALUES ("test\_data")
*   Slave重启后，START SLAVE
*   停止Master的写入
*   等待Slave跟Master完成同步
*   有可能性：Slave上的test中没有“test\_data”

## 背景知识

### 一些配置

#### tokudb\_commit\_sync

TokuDB在Commit前会保证Redo日志写入磁盘

#### relay\_log\_info\_repository = TABLE & relay\_log\_recovery = ON

在Slave上回放一个事务时，使得以下两个操作具有原子性

*   对事务的执行
*   Master\_log\_name/Master\_log\_pos的更新

**log\_slave\_updates**

开启这个参数后，从库会将SQL线程执行的事务同时写入到自身的Binlog里

## 分析

### 两阶段提交时，Coordinator Crash

Coordinator / Storage Engine A / Storage Engine B：

*   A Prepare
*   B Prepare
*   A Commit
*   Coordinator Crash ...

那么当Coordinator重启后，接下来要怎么做？

1.  因为检查到A Commit，通知B Commit，**数据一致**
2.  让B自行处理（B会回滚），**数据不一致**

接下来看MySQL Server如何处理这个场景

**MySQL基于Binlog的Crash Recovery过程**

很重要的一点是，MySQL基于Binlog的Crash Recovery的过程，会使用Binlog辅助引擎完成处于Prepare阶段（还未Commit）的事务

mysqld进程 （MySQL Server层，Coordinator角色） / Binlog / InnoDB / TokuDB

【Prepare】

*   Binlog Prepare
*   TokuDB Prepare
*   InnoDB Prepare  
    

【Commit】

Commit过程的核心函数是ordered\_commit，分为三个阶段：Flush Stage / Sync Stage / Commit Stage（详细参考[MySQL 5.6 Binlog Group Commit]，也就是说一定是Binlog先Commit，然后是各个存储引擎的提交

*   Binlog Commit （Flush Stage和Sync Stage）
*   InnoDB Commit
*   mysqld Crash ...
*   msyqld 重启

这里说一下MySQL Server重启后的Crash Recovery，可以很清晰的看到MySQL Server是如何使用Binlog来辅助各个存储引擎来进行Crash Recovery

```plain
xarecover_handlerton(... xids ...)
  // 这里以innodb进行说明
| if (hton->state == SHOW_OPTION_YES && hton->recover)
    // 调用引擎插件的recover函数
    // innodb会解析redo log，读取出所有处于prepare状态的事务，返回事务的xid
    while ((got= hton->recover(hton, info->list, info->len)) > 0)
        // 遍历引擎插件返回的xid数组
        // innodb的redo log中处于prepare状态的事务xid 
        for (int i= 0; i < got; i++)
            // 在最后一个binlog中读取的xid的hash桶（传入参数）查找xid
            // 如果找到了，说明该事务记录了binlog，则commit，找不到则rollback
            if ( my_hash_search(info->commit_list, (uchar *)&x, sizeof(x)) != 0 :
                hton->commit_by_xid(hton, info->list + i);
            else
                hton->rollback_by_xid(hton, info->list + i);
```

###  Slave Crash Safe

当开启了relay\_log\_info\_repository = TABLE & relay\_log\_recovery = ON

Slave在执行Relay Log时，会使用两阶段提交来保证如下两个操作的原子性：

*   对事务的执行
*   Master\_log\_name/Master\_log\_pos的更新

相应的代码在 Xid\_log\_event::do\_apply\_event 中

```plain
Xid_log_event::do_apply_event 
{
   /*
    rli repository being transactional means replication is crash safe.
    Positions are written into transactional tables ahead of commit and the
    changes are made permanent during commit.
   */
  if (rli_ptr->is_transactional())
  {
    // 更新表mysql.slave_relay_log_info
    if ((error= rli_ptr->flush_info(true)))
      goto err;
  }
  ...
  // 两阶段提交
  error= do_commit(thd);
  ...
}
```

```plain
rli_ptr->flush_info最终会调用相应存储引擎的update_row来对mysql.slave_relay_log_info表进行更新
```

**默认情况下mysql.slave\_relay\_log\_info使用InnoDB**，那么Slave上一个事务的执行流程为（以INSERT为例）：

【例1】

*   【1】BEGIN
*   【2】INSERT INTO <table\_name> VALUES ... 
*   【3】ha\_innobase::update\_row（更新**mysql.slave\_relay\_log\_info，COMMIT之前**）
*   【4】COMMIT（Xid\_log\_event）

一个事务里调用的引擎都需要通过函数register\_ha来注册到Server层，形成一个链表（ha\_list）

**因为链表采用类似头部插入的方式，所以两阶段提交的遍历顺序和引擎的注册顺序相反**【例1】中形成的链表为InnoDB=>TokuDB

Commit阶段，会调用：

*    Xid\_log\_event::do\_commit
    *   trans\_commit
        
        *    ha\_commit\_trans：两阶段提交的执行者，参考[Transaction（一）：2 Phase Commit]

【ha\_commit\_trans】

这里省略了跟文章无关的很多细节

MYSQL\_BIN\_LOG::prepare => ha\_prepare\_low

ha\_prepare\_low会遍历所有在这个事务中已注册到Server层的存储引擎，逐个调用Prepare：

*   innobase\_xa\_prepare  
    
*   tokudb\_xa\_prepare

MYSQL\_BIN\_LOG::commit => ha\_commit\_low（如果开启了Binlog，会调用ordered\_commit函数）

ha\_commit\_low会遍历所有在这个事务中注册到Server层的存储引擎，逐个调用Commit：

*   innobase\_commit  
    
*   tokudb\_commit  
    

那么当如下场景发生时：

*   innobase\_xa\_prepare  
    
*   tokudb\_xa\_prepare
*   innobase\_commit（Master\_log\_name/Master\_log\_pos已经更新，因为Commit了，所以无法回滚）
*   mysqld Crash ...

MySQL Server重启后，因为没有了Binlog的辅助Recovery，TokuDB会将已经Prepare的事务回滚（如果有Binlog，Binlog查找到这个事务的Xid，通知TokuDB调用commit\_by\_xid来提交这个事务）

此时

*   Master\_log\_name/Master\_log\_pos已经更新
*   但TokuDB上该事物被回滚
*   Slave重启后也不会继续执行这个事务（Master\_log\_name/Master\_log\_pos已经更新到这个事务之后的位置）

**因此，Slave相对了Master少了部分数据**

## 解决

*   将slave\_relay\_log\_info改为TokuDB表（ALTER TABLE），回避两阶段提交
*   开启Slave的Binlog（log\_slave\_updates = 1），使用Binlog来辅助存储引擎的Crash Recovery，数据一致

## 参考

【1】[Enabling crash-safe slaves with MySQL 5.6](https://www.percona.com/blog/2013/09/13/enabling-crash-safe-slaves-with-mysql-5-6/)

【2】[MySQL Crash-Safe 复制](https://jin-yang.github.io/post/mysql-crash-safe-replication.html)

【3】[mysql源码学习笔记：基于binlog的recovery机制](https://www.2cto.com/database/201708/670386.html)

【4】[MySQL · 功能分析 · 5.6 并行复制实现分析](http://mysql.taobao.org/monthly/2015/08/09/)



