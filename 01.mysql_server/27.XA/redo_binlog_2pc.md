##<center>MySQL的两阶段事务提交是否先写binlog再写redolog也可行？</center>

# 一、下面是目前的MySQL两阶段提交规则：
事务的两阶段提交
​ MySQL为了兼容其他非事务引擎的复制，在server服务层引入了binlog，Binlog负责记录所有引擎中的修改操作，也因为如此，binlog相比redo log更全面，更适合作为复制的媒介使用。

​ MySQL通过两阶段提交解决了服务层binlog与引擎层Innodb的redo log的一致性与协同问题。

* 第一阶段：InnoDB prepare,持有prepare_commit_mutex，并写入到redo log中。将回滚段(undo)设置为Prepared状态，binlog不做任何操作。

* 第二阶段：将事务写入Binlog中，将redo log中的对应事务打上commit标记，并释放prepare_commit_mutex。

​ MySQL以binlog的写入与否作为事务是否成功的标记，innodb引擎的redo commit标记并不是这个事务成功与否的标记。

* 崩溃时：扫描最后一个Binlog文件，提取其中所有的xid。
​
InnoDB维持了状态为Prepare的事务链表，将这些事务的xid与刚刚提取的xid做比较，若存在，则提交prepare的事务，若不存在，回滚。


但是，如果先写binlog再写redolog的话，当崩溃时，如果没有写redolog，那么binlog也删除掉不也能保证binlog和redolog的一致吗？