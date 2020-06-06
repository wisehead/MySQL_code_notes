
# [InnoDB（十六）：DDL]

DDL本是MySQL Server的功能，但也放在InnoDB系列文章里阐述。DDL 的执行主要有两种方式：COPY 和 INPLACE

*   **COPY 指的是 DDL 的过程中需要新建临时表**（e.g 修改列的类型、删除主键）
*   **INPLACE **指的是 DDL 在原表上进行****（e.g 添加 / 删除索引）

INPLACE 依据 “是否需要修改记录的格式” 也有两个分类：Rebuilt（是） / non-Rebuilt（否）：

*   **Rebuilt** 指的是需要修改记录（添加索引、添加 / 删除列）  
    
*   **non-Rebuilt** 指的是不需要修改记录，仅修改数据字典（删除索引、修改列名）  
    

所有的DDL均采用COPY / INPLACE其一的方式实现，但有的DDL在执行过程之中允许写，被称为[online DDL](https://dev.mysql.com/doc/refman/5.7/en/innodb-online-ddl-operations.html)。例如创建索引。而DDL在执行过程之中不允许写的有删除主键

## INPLACE 的方式

Prepare阶段：

*   创建新的临时 frm 文件(与 InnoDB 无关)
    
*   持有 EXCLUSIVE-MDL 锁，禁止读写
    
*   根据 ALTER 类型，确定执行方式（copy，online-rebuild，online-not-rebuild）
    
*   更新数据字典的内存对象
    
*   分配 row\_log 对象记录数据变更的增量（仅 rebuild 类型需要）
    
*   生成新的临时ibd文件 new\_table（仅 rebuild 类型需要）
    

Execute 阶段：

*   降级 EXCLUSIVE-MDL 锁，允许读写
    
*   扫描 old\_table 聚集索引（主键）中的每一条记录（称为 rec）
    
*   遍历 new\_table 的聚集索引和二级索引，逐一处理
    
*   根据 rec 构造对应的索引项
    
*   将构造索引项插入 sort\_buffer 块排序
    
*   将 sort\_buffer 块更新到 new\_table 的索引上
    
*   记录 online-ddl 执行过程中产生的增量（仅 rebuild 类型需要）
    
*   重放 row\_log 中的操作到 new\_table 的索引上（not-rebuild 数据是在原表上更新）
    
*   重放 row\_log 中的 DML 操作到 new\_table 的数据行上
    

Commit 阶段：

*   当前 Block 为 row\_log 最后一个时，禁止读写，升级到 EXCLUSIVE-MDL 锁
    
*   重做 row\_log 中最后一部分增量
    
*   更新 InnoDB 的数据字典表
    
*   提交事务（刷写事务的 redo 日志）
    
*   修改统计信息
    
*   rename 临时 ibd 文件，frm 文件
    
*   变更完成，释放 EXCLUSIVE-MDL 锁
    

## MySQL 8.0：Atomic DDL

### DDL 的 undo 日志 - DDL Log

undo 日志只能保证对主键索引中数据行的修改的原子性（可回滚），而并不记录文件的操作（CREATE TABLE）。因此我们需要增加**另一种 “undo 日志” 来保证非数据页操作的原子性**（可回滚），这种新的 “undo 日志” 叫做 DDL Log。**与 undo 日志相同，DDL Log 也是逻辑日志**，DDL Log 回滚原理也是执行**原操作的反向操作**来达到“回滚的效果”。

在修改数据行时先记录 undo 日志，再修改数据页。相同的，比如在执行 CREATE TABLE 创建 ibd 文件之前，先记录 DDL Log

```plain
dict_build_tablespace_for_table
  // 写入创建 ibd 文件的 DDL Log，记录的是反向操作 "delete space"
  |- log_ddl->write_delete_space_log
  // 创建 ibd 文件
  |- fil_ibd_create
```

### Post DDL

DDL 的执行过程也采用**延迟操作**的策略来保证事务回滚的效率。比如 DROP TABLE 的事务，不会在事务提交之前就删除 ibd 文件，否则事务需要回滚怎么办？（类似于 InnoDB DELETE SQL 时将数据行标记为 delete mark，随后再由 purge 线程删除）

此处将删除 ibd 文件的操作记录到 DDL Log 里，在事务提交后，再通过 DDL Log 里的日志记录删除 ibd 文件。这便是 Post DDL 的意思

  
CREATE TABLE 的详细分析

设置 `[innodb_print_ddl_logs](https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_print_ddl_logs) = ON，可以在执行 DDL 的过程中打印出 DDL log。接下来我们详细的分析 CREATE TABLE：`

*   DELETE\_SPACE\_LOG：删除表空间文件
    
*   REMOVE\_CACHE\_LOG：在 dict cache 删除该表
    
*   FREE\_TREE\_LOG：删除表空间的一个索引
    

（未完待续）

## 参考

*   [简介-online DDL过程介绍](https://cloud.tencent.com/developer/article/1006513)
*   [MySQL Add Index实现](http://hedengcheng.com/?p=421)
*   [14.13.1 Online DDL Operations](https://dev.mysql.com/doc/refman/5.7/en/innodb-online-ddl-operations.html#online-ddl-index-syntax-notes)
*   [在？上次你问对大型表的DDL操作，我找到好方法了](https://dbaplus.cn/news-11-2552-1.html)
*   [WL#9536: InnoDB\_New\_DD: Support crash-safe DDL](https://dev.mysql.com/worklog/task/?id=9536)
*   [WL#4284: Transactional DDL locking](https://dev.mysql.com/worklog/task/?id=4284)
*   [Atomic DDL in MySQL 8.0](https://mysqlserverteam.com/atomic-ddl-in-mysql-8-0/)
*   [详解MySQL-8.0数据字典](https://cloud.tencent.com/developer/article/1427699)


