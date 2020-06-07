

# [GTID（四）：乱序的GTID]

## 概念

我们先介绍两个系统变量

#### binlog\_order\_commits

MySQL 5.6.6引入，默认开启

事务按照在binlog中写入的顺序进行commit

#### slave\_preserve\_commit\_order

MySQL 5.7.5引入，默认关闭

在并行复制场景下，事务在Slave上commit与在Msater上的commit的顺序保持一致

接下来分析什么场景可能出现乱序的GTID

## 并行复制

在并行复制场景下，5.7.7之前因为没有slave\_preserve\_commit\_order，并不保证事务在Slave上commit与在Msater上的commit的顺序一致

*   如果Master是事务顺序提交，GTID严格递增
*   在Slave上，可能由于并行复制导致事务的提交顺序与Master上并不一致，那么Slave的GTID就产生了“局部乱序”

## 人为修改GTID\_NEXT

*   如果当前gtid\_executed为server\_uuid:1-10
*   设置gtid\_next = server\_uuid:15
*   执行事务A，A的GTID为server\_uuid:15
*   设置gtid\_next = AUTOMATIC
*   执行事务B，B的GTID为server\_uuid:11

那么A，B的GTID就是“局部乱序”的，binlog中的记录类似这样：

```java
...
server_uuid:10
server_uuid:15
server_uuid:11
...
```



