# [MySQL中启用GTID配置]

## 背景

### 概念

每个GTID（Global Transaction ID，全局事物ID）标识了一个数据库事物，在基于主/从复制的集群中全局唯一。GTID的格式为：

 **GTID = source\_id:transaction\_id**

*   source\_id：主库的server\_uuid（128位）  
    首次启动MySQL时会调用[mysqld.cc](http://mysqld.cc/)中的**generate\_server\_uuid**函数根据配置文件（my.cnf）中的配置项**_s_****_erver-id_**生成，并保证每台server的 server\_uuid不同  
    （每个MySQL server的server\_uuid保存在_path\_to\_mysql / data\_dir / auto.cnf_ ）  
    再次启动MySQL时会读取auto.cnf中的server\_uuid
*   transaction\_id：主库的事物序列号  
    从1开始自增计数，表示在主库上执行的第transaction\_id个事务

e.g d9dd8550-1f4c-11e7-a44b-cbca9484dbbd:5

### 作用

原主库宕机切换主库时，传统的复制方式中，从库指向新主库的复制方式如下，往往需要人工指定<file\_name>、<position\_number>参数，这是个很麻烦费时的过程。

```sql
CHANGE MASTER TO MASTER_HOST='<address>', MASTER_USER='<user_name>', MASTER_PORT=<port_number>, MASTER_PASSWORD='<password>', MASTER_LOG_FILE='<file_name>', MASTER_LOG_POS=<position_number>;
```

而当所有事务具有全局唯一的GTID时，可以更简单的、自动的进行failover，如下

```sql
CHANGE MASTER TO MASTER_HOST='<address>', MASTER_PORT=<port>, MASTER_USER='<user_name>',MASTER_PASSWORD='<password>', MASTER_AUTO_POSITION=1;
```

### 配置项

MySQL默认不开启GTID的配置

```sql
mysql> show variables like '%gtid%'; 
+---------------------------------+-----------+
| Variable_name                   | Value     |
+---------------------------------+-----------+
| binlog_gtid_simple_recovery     | OFF       |
| enforce_gtid_consistency        | OFF       |
| gtid_deployment_step            | OFF       |
| gtid_executed                   |           |
| gtid_mode                       | OFF       |
| gtid_next                       | AUTOMATIC |
| gtid_owned                      |           |
| gtid_purged                     |           |
| simplified_binlog_gtid_recovery | OFF       |
+---------------------------------+-----------+
```

一些相关的配置项：

*   **enforce\_gtid\_consistency**  
    开启后，MySQL只允许能够保障事务安全，并且能够被日志记录的SQL语句被执行，像`CREATE TABLE ... SELECT`和 `CREATE TEMPORARY TABLE`语句，以及同时更新事务表和非事务表的SQL语句或事务都不允许执行。而且在开启gtid\_mode前，必须开启enforce\_gtid\_consistency。可能取值：
    *   false（默认）
    *   true  
          
        
*   **gtid\_mode**  
    是否对于事务执行开启GTID模式，开启前必须保证`log-bin`, `log-slave-updates`, and `enforce-gtid-consistency都开启，可能取值：`
    *   off（默认）
    *   on  
          
        
*   **log-bin**：  
    开启binary logging  
      
    
*   **binlog-format**  
    MySQL支持的复制模式，可能取值：
    *   **row：基于行的复制，最安全的复制模式，开启GTID时推荐的设置**
    *   statement：基于语句的复制
    *   mixed：混合复制  
          
        
*   **log-slave-updates**：  
    通常，从库并不将从主库接收到的更新写入到自身的binlog里，开启这个参数后，从库会将SQL线程执行的更新写入到自身的binlog里，同时要求从库的log-bin必须开启。用于存在server既是主库又是从库时。可能取值：
    *   off（默认）
    *   on  
          
        
*   **gtid\_next**  
    如何产生下一个GTID，可能取值：

*   AUTOMATIC：自动生成下一个GTID，分配一个当前实例上尚未执行过的序号最小的GTID
    
*   ANONYMOUS：事务不会产生GTID
    
*   UUID:NUMBER：显示指定GTID
    

## 主从复制

### 初始化的集群搭建

最简单的场景，当主库/从库都初次启动时，从零搭建

#### 1，修改主库（Master）配置文件my.cnf

添加如下配置项，并重启主库的MySQL服务

```plain
# GTID
binlog-format                = ROW    
log-bin                      = master-bin    
log-bin-index                = master-bin.index    
log-slave-updates            = true    
gtid-mode                    = on    
enforce-gtid-consistency     = true
# 确保不同server的server-id不同 
server-id                    = <server id>
```

#### 2，修改从库（Slave）配置文件my.cnf

添加如下配置项，并重启从库的MySQL服务

```plain
# GTID
binlog-format                = ROW    
log-bin                      = master-bin    
log-bin-index                = master-bin.index    
log-slave-updates            = true    
gtid-mode                    = on    
enforce-gtid-consistency     = true
# 确保不同server的server-id不同 
server-id                    = <server id>
```

#### 3，主库授予从库权限

```sql
GRANT REPLICATION SLAVE ON *.* TO '<user_name>'@'<adress>' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

#### 4，将从库指向主库

*   建议在主库建立一个用户（user\_name / password），只授予此用户从库复制所需要的权限，以避免“Troubleshooting 3. 安全警告”的问题
*   MASTER\_AUTO\_POSITION会告知从库，事务由GTID标识
    

```sql
CHANGE MASTER TO MASTER_HOST='<address>', MASTER_PORT=<port>, MASTER_USER='<user_name>',MASTER_PASSWORD='<password>', MASTER_AUTO_POSITION=1;
```

#### 5，从库启动复制

```plain
START SLAVE;
```

### 运行中的集群搭建

等同于为使用基于file-pos复制模式的Master/Slave**在线迁移为**使用GTID复制模式，参考[这里](https://dev.mysql.com/doc/refman/5.6/en/replication-gtids-failover.html)

#### 1，设置主库为read-only，**等待Slave完成数据同步（十分重要）**

#### 2，停止两个server

#### 3，将两个server设置GTID（方法同上“初始化的集群搭建”），重启（_重启顺序无所谓，Slave推荐加入 `[--skip-slave-start](https://dev.mysql.com/doc/refman/5.6/en/replication-options-slave.html#option_mysqld_skip-slave-start)参数`_）

#### 4，关闭主库read-only

## 创建备份

### Master已启用GTID

#### **普通创建方法**

等同于“初始化的集群搭建”中省略“步骤1”，但是同步时间可能会很漫长

#### **快速创建方法**

参考[官方文档](https://dev.mysql.com/doc/refman/5.6/en/replication-gtids-failover.html#replication-gtids-failover-gtid-purged)和[这篇博客](https://my.oschina.net/anthonyyau/blog/625076)

*   备份Master数据，master\_data/
    *   mysqldump
    *   xtrabackup，**以下围绕xtrabackup进行说明**
*   将master\_data/拷贝至Slave data/目录下
*   配置Slave并启用
*   查看data/下xtrabackup\_binlog\_info，类似：
    
    ```plain
    $ cat xtrabackup_binlog_info 
    mysql-bin.000012    46455554    8133046e-4282-11e6-848e-026ca51d284c:1-4920155
    ```
    
*   Slave设置@@global.gtid\_purged，以跳过备份包含的GTID
    
    ```sql
    mysql> SET GLOBAL gtid_purged="8133046e-4282-11e6-848e-026ca51d284c:1-4920155";
    ```
    
*   Slave指定Master为主库
    
    ```sql
    CHANGE MASTER TO MASTER_HOST='<address>', MASTER_PORT=<port>, MASTER_USER='<user_name>',MASTER_PASSWORD='<password>', MASTER_AUTO_POSITION=1; 
    ```
    

### Master未启用GTID

将Slave和Master同步后，参照“运行中的集群搭建”

## 查看

介绍一些常见的命令可以查看与GTID相关的参数信息

*   **查看和GTID相关的系统变量**
    
    ```sql
    SHOW VARIABLES LIKE '%GTID%';
    ```
    
    正常状态下，binlog应该是开启的，Position应该是非零值
    
*   **查看主从同步完成的情况**
    
    ```plain
    SHOW PROCESSLIST\G;
    ```
    
*   **查看主库（从库）状态**
    
    ```plain
    SHOW MASTER(SLAVE) STATUS\G;
    ```
    
    正常情况从库的`Slave_IO_Running和``Slave_SQL_Running应该都是Yes才对`
    

## Troubleshooting

当从库的复制或者同步发生异常时，需要进行排错。主要参考[MySQL Troubleshooting Replication](https://dev.mysql.com/doc/refman/5.7/en/replication-problems.html)，再结合自身的经验

#### 1\. 主/从库的server\_uuid是否不同？

主从复制必须保证主库/从库的server\_uuid不同

*   查看_path\_to\_mysql / data\_dir / auto.cnf_文件
*   如果相同，可以删除auto.cnf后，重新启动server

#### 2\. server是否设置了忽略某些数据库的主/从库复制？

```plain
# replication
replicate-wild-ignore-table     = mysql.%
replicate-wild-ignore-table     = test.%
```

#### 3\. 安全性警告

```plain
从库执行CHANGE MASTER TO ... 命令后会产生2 Warnings
```

```sql
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Level | Code | Message                                                                                                                                                                                                                                                                              |
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 
| Note  | 1759 | Sending passwords in plain text without SSL/TLS is extremely insecure.                                                                                                                                                                                                               |
 
| Note  | 1760 | Storing MySQL user name or password information in the master info repository is not secure and is therefore not recommended. Please consider using the USER and PASSWORD connection options for START SLAVE; see the 'START SLAVE Syntax' in the MySQL Manual for more information. |
 
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

主要原因是从库将主库信息以明文形式保存在_path\_to\_mysql / data\_dir / [master.info](http://master.info/)_中

### 主库异常宕机--mysqlfailover

#### 作用

主库宕机后，可能导致主库和从库的GTID集合不一致。此时存在一些复杂场景，在异步模式下，从库的binlog可能慢于主库；半同步模式下，主库的binlog可能慢于从库。但可以通过MySQL[工具库](https://dev.mysql.com/doc/mysql-utilities/1.6/en/)专有工具[mysqlfailover](https://dev.mysql.com/doc/mysql-utilities/1.5/en/mysqlfailover.html)来完成自动换主

mysqlfailover要求集群启用GTID，如果集群没有启用GTID，那么你可能需要以下的方式来完成换主：

*   使用应用或脚本来监控主库的状态
*   当检测到主库宕机，在从库集群中选择指定从库作为新主库
*   将其与从库使用 **[`CHANGE MASTER TO`](https://dev.mysql.com/doc/refman/5.7/en/change-master-to.html)** 指向新主库

#### 原理

mysqlfailover做了如下的工作：

*   集群拓扑结构为一主多从，并且集群启用GTID（5.6.5及以上版本）
*   周期性的监控集群主库运行状态
    *   Ping命令判断主库是否可达
    *   使主库执行一些基础的命令判断主库是否正常运行（e.g **SHOW DATABASES**）
*   当主库发生故障/宕机后，自动选择合适的从库并且完成主库的切换，切换方式有以下三种
    
    1.  **auto**（默认）  
        *   检查是否有指定的candidates list，如果candidates list为空，返回第一个存活并且可以升级为Master的Slave（判断依据见**附录**），作为Candidate（如果没有存活的Slave，产生error并exit）
        *   将Candidate依次作为其余Slave的Slave，进行日志的up-to-date，来保证Candidate的日志在所有Slave中最新（most up-to-date），只有在GTID模式下，这个步骤才可以自动的轻易完成
        *   Candidate升级为Master，将其余Slave指向Master  
            
    2.  **elect**  
        *   当candidates list为空时，将产生error并exit，其余同**auto**方式
    3.  **fail**
    
    *   *   当Master宕机后，将产生error并exit。这种方式只用于监控，不进行failover

#### 设置

*   所有Slave要添加一下配置项，注意report-host和report-port的配置
    
    ```plain
    report-host               = <slave_itself_address>
    report-port               = <slave_itself_port>
    master-info-repository    = TABLE
    relay-log-info-repository = TABLE
    ```
    
*   连接Master：
    
    *   交互式模式
        
        ```sql
        mysqlfailover --master=<user_name>@<address> --discover-slaves-login=<user_name>[:<password>]
        ```
        
    *   守护者模式：日志不在console展示，而是记录到日志文件里，因而需要--log配置项
        
        ```sql
        mysqlfailover --master=<user_name>@<address> --discover-slaves-login=<user_name>[:<password>] --daemon=start|stop|restart|nodetach --log=<log_path>
        ```
        
        其中：
        
        *   ```plain
            --discover-slaves-login=<user_name>[:<password>]
            ```
            
            user\_name和password用于mysqlfailover连接Master，进而查询Slaves信息
            
        
        如果进入交互式命令窗口，提供如下的一些指令
        
        *   Q - quit 
        *   R - refresh 
        *   H - health：UP（可以connect，可以ping），WARN（不可以connect，可以ping），DOWN（不可以ping）
        *   G - GTID Lists 
        *   U - UUIDs
        
        当Master出现故障后，就可以自动进行failover了，日志类似如下：
        
        ```plain
        Failed to reconnect to the master after 3 attemps.
        Failover starting in 'auto' mode...
        # Candidate slave <address>:<port> will become the new master.
        # Checking slaves status (before failover).
        # Preparing candidate for failover.
        # Creating replication user if it does not exist.
        # Stopping slaves.
        # Performing STOP on all slaves.
        # Switching slaves to new master.
        # Disconnecting new master as slave.
        # Starting slaves.
        # Performing START on all slaves.
        # Checking slaves for errors.
        # Failover complete.
        # Discovering slaves for master at <address>:<port>
        ```
        

## GTID的局限性

*   对于如下的语句

```sql
CREATE TABLE ... SELECT
```

是在日志中记录了两个独立的事件：

*   *   产生一个新表
    *   将源表的行插入新表

但是可能在某些场景下这两个独立的事件产生了相同的GTID，违背了GTID的意义，同理以下语句也是不可以的

```sql
CREATE
TEMPORARY
TABLE
DROP
TEMPORARY
TABLE
```

*   GTID模式下不允许事务中同时更新事务引擎（如InnoDB）表和非事务引擎（如MyISAM）表

## 附录

*   mysqlfailover从Slave中选择新主的判断依据

<table style="margin-left: 30.0px;" class="confluenceTable"><tbody style="margin-left: 30.0px;"><tr style="margin-left: 30.0px;"><td style="margin-left: 60.0px;" class="confluenceTd"><em><strong>CONNECTED</strong></em></td><td style="margin-left: 60.0px;" class="confluenceTd">Slave可以连接到Master</td></tr><tr style="margin-left: 60.0px;"><td style="margin-left: 60.0px;" class="confluenceTd"><em><strong>GTID</strong></em></td><td style="margin-left: 60.0px;" class="confluenceTd">Slave启用GTID（如果Master启用GTID）</td></tr><tr style="margin-left: 60.0px;"><td style="margin-left: 60.0px;" class="confluenceTd"><em><strong>BEHIND</strong></em></td><td style="margin-left: 60.0px;" class="confluenceTd">Slave不落后与Master（只用于未开启GTID）</td></tr><tr style="margin-left: 60.0px;"><td style="margin-left: 60.0px;" class="confluenceTd"><em><strong>FILTER</strong></em></td><td style="margin-left: 60.0px;" class="confluenceTd"><p>检查Master/Slave的数据库复制过滤是否一致</p><p>主要涉及以下配置项：</p><ul><li style="list-style-type: none;background-image: none;"><ul><li>binlog-do-db / binlog-ignore-db</li><li>replicate-do-db / replicate-ignore-db</li></ul></li></ul></td></tr><tr style="margin-left: 60.0px;"><td style="margin-left: 60.0px;" class="confluenceTd"><em><strong>RPL_USER</strong></em></td><td style="margin-left: 60.0px;" class="confluenceTd">检查Slave user_name和address存在</td></tr><tr style="margin-left: 60.0px;"><td style="margin-left: 60.0px;" class="confluenceTd"><em><strong>BINLOG</strong></em></td><td style="margin-left: 60.0px;" class="confluenceTd">检查Slave的binlog启用</td></tr></tbody></table>



