

# [GTID（五）：Retrieved\_Gtid\_Set中的最后一个“GTID”]

## MySQL < 5.6.15

在Master/Slave复制模型下：

*   【1】Slave收到Gtid\_log\_event就会把GTID记录到Retrieved\_Gtid\_Set
*   【2】如果此时Master突然宕机/网络断开等，Slave收到的这个事务并不完整，记为last\_retrieved\_gtid
*   【3】Slave执行此事务时，由于失败会回滚，因此Executed\_Gtid\_Set并不会记录这个GTID
*   【4】当Master恢复后或者Slave指向一个新的Master
    *   【4.1】Slave会把Slave\_Gtid\_Set = Retrieved\_Gtid\_Set + Executed\_Gtid\_Set的并集发送给Master
    *   【4.2】Master将自身的Executed\_Gtid\_Set - Slave\_Gtid\_Set的差集发送给Slave（Master认为Slave没有执行这些GTIDs）
    *   【4.3】因为last\_retrieved\_gtid包含在Slave\_Gtid\_Set中（Slave的Retrieved\_Gtid\_Set中）
    *   【4.4】所以Slave不会再收到这个last\_retrieved\_gtid  
        
    *   【4.5】Master/Slave上很有可能造成了数据不一致

## 5.6.15 <= MySQL < 5.7.5

MySQL 5.6.15加入了[这个patch](https://github.com/mysql/mysql-server/commit/e7a4cbe6a6449989e483d46abe79169f717a0725)

在 **“MySQL < 5.6.15”**【4.1】中，Slave做如下检查：

*   【4.1.1】如果last\_retrieved\_gtid包含在Retrieved\_Gtid\_Set中，Slave认为这个GTID执行过，发送给Master的集合如下：
    *   Slave\_Gtid\_Set = （Retrieved\_Gtid\_Set - last\_retrieved\_gtid）+ Executed\_Gtid\_Set  
        
*   【4.1.2】如果last\_retrieved\_gtid不包含在Retrieved\_Gtid\_Set中，Slave认为这个GTID没有执行过，发送给Master的集合如下：
    *   Slave\_Gtid\_Set = Retrieved\_Gtid\_Set + Executed\_Gtid\_Set

咋看起来没问题，但是会产生[Bug #72392](https://bugs.mysql.com/bug.php?id=72392)，根本原因在于：

*   “如果last\_retrieved\_gtid不包含在Retrieved\_Gtid\_Set中，Slave认为这个GTID没有执行过”**是错误的**  
    

### Bug #72392

**【场景】**

 Master/Slave使用GTID复制

```sql
-- Master
mysql> create table t1 (a int, b int) engine=innodb;
mysql> insert into t1 values(1,1);
mysql> insert into t1 values(2,2);
mysql> insert into t1 values(3,3);
mysql> insert into t1 values(4,4);
mysql> select * from t1;
+------+------+
| a    | b    |
+------+------+
|    1 |    1 |
|    2 |    2 |
|    3 |    3 |
|    4 |    4 |
+------+------+
-- Slave
mysql> reset master;
mysql> stop slave;
mysql> start slave;
mysql> select * from t1;
+------+------+
| a    | b    |
+------+------+
|    1 |    1 |
|    2 |    2 |
|    3 |    3 |
|    4 |    4 |
|    4 |    4 |
+------+------+
```

【原因分析】

```plain
在Slave上执行RESET MASTER会导致：
```

*   **Executed\_Gtid\_Set清空**
*   **Retrieved\_Gtid\_Set不变**

那么继续START SLAVE时：

*   Slave的Retrieved\_Gtid\_Set中的last\_retrieved\_gtid **( insert into t1 values(4,4) )**并不包含在Executed\_Gtid\_Set（因为Executed\_Gtid\_Set为空）
*   Slave会将（Retrieved\_Gtid\_Set - last\_retrieved\_gtid）+ Executed\_Gtid\_Set发送给Master
*   Master会将last\_retrieved\_gtid再次发送过来
*   因为Executed\_Gtid\_Set为空，所以Slave会再次执行last\_retrieved\_gtid **( insert into t1 values(4,4) )**
*   因此Master/Slave出现了数据不一致
*   这个Bug的修复方法见

## MySQL >= 5.7.6 

在MySQL 5.7.6中加入了[这个patch](https://github.com/mysql/mysql-server/commit/9dab9dad975d09b8f37f33bf3c522d36fdf1d0f9)，加入了GTID事务的“边界检测功能”（Transaction Boundary Parser）

在 **“MySQL < 5.6.15”**【1】中

*   Slave收到Gtid\_log\_event时不会立即加入Retrieved\_Gtid\_Set
*   使用Transaction Boundary Parser，只有当I/O线程收到完整的GTID事务，才会将这个GTID添加到Retrieved\_Gtid\_Set
*   因此即使Master出现突然宕机等情况，也能保证Retrieved\_Gtid\_Set的last\_retrieved\_gtid一定是完整的事务



