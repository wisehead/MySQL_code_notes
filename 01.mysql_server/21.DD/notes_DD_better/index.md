---
title: MySQL-8.0 | 数据字典最强解读
category: default
tags: 
  - xw.qq.com
created_at: 2020-11-12 16:05:23
original_url: https://xw.qq.com/cmsid/20190425A01YU900
---


# MySQL-8.0 | 数据字典最强解读

公众号展示代码会自动折行，建议横屏阅读

**1\. 引言**

数据字典(Data Dictionary)中存储了诸多数据库的元数据信息如图1所示，包括基本Database, table, index, column, function, trigger, procedure，privilege等；以及与存储引擎相关的元数据，如InnoDB的tablespace, table\_id, index\_id等。MySQL-8.0在数据字典上进行了诸多优化，本文将对其进行逐一介绍。

![图1](assets/1605168323-15cd5c484a728932aa949fc124e6cdb3.webp)

打开腾讯新闻，查看更多图片 >

图1

## 2\. MySQL-8.0之前的数据字典

俗话说知己知彼，方能百战不殆。在介绍MySQL-8.0的数据字典前，我们先一起回顾一下MySQL-8.0之前的数据字典。

**2.1 Data Dictionary 分布位置**

![图2](assets/1605168323-2b25941a00183f46b12a7a1b8610c00f.webp)

图2

如图2所示，旧的数据字典信息分布在server层，mysql库下的系统表和InnoDB内部系统表三个地方，其中保存的信息分别如下所示：

server层文件

.frm files: Table metadata files.

.par files: Partition definition files. InnoDB stopped using partition definition files in MySQL 5.7 with the introduction of native partitioning support for InnoDB tables.

.TRN files: Trigger namespace files.

.TRG files: Trigger parameter files.

.isl files: InnoDB Symbolic Link files containing the location of file-per-table tablespace files created outside of the data directory.

.db.opt files: Database configuration files. These files, one per database directory, contained database default character set attributes.

mysql库下的系统表

mysql.user mysql.db mysql.proc mysql.event等

show tables in mysql；

InnoDB内部系统表

SYS\_DATAFILES

SYS\_FOREIGN

SYS\_FOREIGN\_COLS

SYS\_TABLESPACES

SYS\_VIRTUAL

2.2 存在的问题

数据字典分散存储，维护管理没有统一接口

MyISAM系统表易损坏

DDL没有原子性，server层与innodb层数据字典容易不一致

文件存储数据字典扩展性不好

通过information\_schema查询数据字典时生成临时表不友好

## 3\. MySQL-8.0的数据字典

鉴于旧数据字典的种种缺点，MySQL-8.0对数据字典进行了较大的改动：把所有的元数据信息都存储在InnoDB dictionary table中，并且存储在单独的表空间mysql.ibd里，其架构如图3所示。下面逐一介绍各项改变的细节。

![图3](assets/1605168323-d2548a13cd439b83556a58149b36fb6c.webp)

图3

3.1 存储结构

MySQL下的原有系统表由MyISAM转为了InnoDB表，没有了proc和event表，直接改存到了dictionary table中。在debug模式下，可用如下指令查看dictionary tables：

3.2 Dictionary Object Cache

数据字典表信息可以通过全局的cache进行缓存。

table\_definition\_cache：存储表定义

schema\_definition\_cache：存储schema定义

stored\_program\_definition\_cache：存储proc和func定义

tablespace\_definition\_cache：存储tablespace定义

另外还有character，collation，event，column\_statistics也有cache，不过其大小硬编码不可配置：

3.3 Information\_schema

![图4](assets/1605168323-4fa8ba1ff68516e4c35639732951b429.webp)

图4

information\_schema的变化如图4所示，主要包括以下几个方面：

**1\. information\_schema部分表名变化**

**2\. 通过information\_schema查询时不再需要生成临时表获取，而是直接从数据字典表获取**

**3\. 不需要像以前一样扫描文件夹获取数据库列表，不需要打开frm文件获取表信息，而是直接从数据字典表获取**

**4\. information\_schema查询以view的形式展现，更利于优化器优化查询**

3.4 优点

去掉server层的元数据文件，元数据统一存储到InnoDB数据字典表，易于管理且crash-safe

支持原子DDL

information\_schema查询更高效

## 4\. Serialized Dictionary Information (SDI)

MySQL8.0不仅将元数据信息存储在数据字典表中，同时也冗余存储了一份在SDI中。对于非InnoDB表，SDI数据在后缀为.sdi的文件中，而对于innodb，SDI数据则直接存储与ibd中，如以下例子所示：

4.1 非事务表

上述例子中MyISAM表t2的SDI为test/t2\_337.sdi，其中337为table\_id, t2\_337.sdi可以直接打开，数据是json格式(cat test/t2\_337.sdi)：

4.2 InnoDB事务表

上述例子中的InnoDB表t1的SDI则可以通过工具ibd2sdi可以解析出来(ibd2sdi test/t1.ibd)：

SDI在ibd中实际是以表（BTree)的形式存储的。建表时会通过btr\_sdi\_create\_index建立SDI的BTree，同时会向BTree插入table和tablespace的SDI信息，表的结构如下：

4.3 其他表空间的SDI

ibd2sdi mysql.ibd，可以查看所以mysql下的表，包括new dictionary和mysql下的普通表。需要注意的是ibdata1中不存放SDI信息，使用ibd2sdi解析它会出现以下提示：

\[INFO\] ibd2sdi: SDI is empty.

4.4 import

import (import table \*.sdi)只支持MyISAM表，InnoDB不支持。由于SDI不包含trigger信息，所以import也不会导入trigger信息，trigger需额外处理。

## 5\. Data Dictionary存取实现

例如create table 会涉及到mysql.tablespaces,mysql.tablespace\_files, mysql.tables, mysql.indexes, mysql.columns,mysql.index\_column\_usage等。create table的过程如图5所示：

![图5](assets/1605168323-fd227523bdd6d0bf3cb1f9ff2cb7adf4.webp)

图5

下面以表t1为例，演示create table在DD中的数据分布：

drop table是create table的逆过程，不再具体分析。

**

## 6\. Initialize

**

![图6](assets/1605168323-474d04b995c08cdd0a2be8e9486087f4.webp)

图6

mysqld --initialize的源码流程如图6所示。具体过程为：

## 7\. Atomic DDL

## 7.1 Atomic DDL

定义：DDL所涉及的以下更改操作是原子的，这些更改操作要么都提交，要么都回滚。

data dictionary

storage engine

binary log

只有InnoDB engine支持Atomic DDL，以下操作不支持：

Table-related DDL statements that involve a storage engine other than InnoDB.

INSTALL PLUGIN and UNINSTALL PLUGIN statements.

INSTALL COMPONENT and UNINSTALL COMPONENT statements.

CREATE SERVER, ALTER SERVER, and DROP SERVER statements.

**7.2 DDL log**

DDL过程中操作DD事物表是原子的，而DDL过程中也会操作文件，创建和释放BTree以及修改DD cache，这些操作不是原子的。为了实现atomic DDL， DDL过程中对文件操作和Btree操作等记录日志，这些日志会记录到DD表mysql.innodb\_ddl\_log中。日志有以下几个类型：

mysql.innodb\_ddl\_log 表结构如下：

将DDL分为以下几个阶段, Prepare记录DDL log，Post-DDL会replay log来提交或回滚DDL操作，同时也并清理DDL log。

**7.3 Atomic DDL Examples**

**7.3.1 drop table**

以drop table为例，drop 过程中会删除ibd文件，也会从mysql.innodb\_dynamic\_metadata 中删除相应记录。

在preppare阶段只是记录日志，没有真正删除。如果drop过程成功, innobase\_post\_ddl才从mysql.innodb\_ddl\_log中读取记录去replay，replay\_delete\_space\_log/replay\_drop\_log会真正执行删除, replay完也会清理ddl log；如果drop过程失败，rollback时mysql.innodb\_ddl\_log的记录也回滚了，innobase\_post\_ddl时没有记录需要replay。

**7.3.2 create table**

drop table post\_ddl阶段执行的redo操作，而create table post ddl执行的是rollback操作。create table prepare阶段会真正的创建ibd，BTree，修改DD share cache， 同时记录相应的log到mysql.innodb\_ddl\_log中。

如果DDL成功commit，在post-DDL阶段，DDL log记录被清理了，不需要replay。如果DDL失败rollback，在post-DDL阶段，DDL log清理操作也回滚了，需要replay， relay会rollback前面的创建ibd，BTree，以及修改DD share cache。

如果create table过程中发生crash， 重启后会读取ddl log完成ddl的回滚。

如果create table过程中发生crash， 重启后会读取ddl log完成ddl的回滚。

**7.3.3 truncate table**

truncate 先rename 为临时ibd，然后drop临时ibd，再重建表。rename会记录ddl log, 参考write\_rename\_space\_log函数，删除重建也会记录ddl log, 同前面介绍的create/drop table, 可以做到原子。rollback时通过日志将临时ibd重命名为原ibd，参考replay\_rename\_space\_log函数。

## 7.4 Atomic DDL带来的变化

## drop 多表或多用户时，如果个别失败，整个DDL都会回滚，且不会记录binlog；而在MySQL8.0以前, 部分DDL会成功且整个DDL会记录binlog。

8\. Persistent Autoinc

MySQL8.0以前自增值没有持久化，重启时通过select MAX(id)的方式获取当前自增值，这种方式自增值会重复利用。MySQL8.0开始支持自增值持久化，通过增加redo日志和Data Dictonary 表mysql.innodb\_dynamic\_metadata来实现持久化。

每次insert/update更新自增值时会将自增值写到redo日志中，参考dict\_table\_autoinc\_log函数，日志格式如下：

同时dict\_table\_t增加了新的变量autoinc\_persisted, 在每次checkpoint时会将autoinc\_persisted存储到表mysql.innodb\_dynamic\_metadata中。

dict\_table从dictionary cache淘汰时也会将autoinc\_persisted持久化到mysql.innodb\_dynamic\_metadata中。

dict\_table从dictionary cache淘汰时也会将autoinc\_persisted持久化到mysql.innodb\_dynamic\_metadata中。

crash重启时，先从mysql.innodb\_dynamic\_metadata获取持久化的自增值，再从redo日志中读取最新的自增值, 参考MetadataRecover::parseMetadataLog，并通过MetadataRecover::apply更新到table->autoinc。

crash重启时，先从mysql.innodb\_dynamic\_metadata获取持久化的自增值，再从redo日志中读取最新的自增值, 参考MetadataRecover::parseMetadataLog，并通过MetadataRecover::apply更新到table->autoinc。

## 9\. Upgrade

## MySQL-8.0不支持跨版本升级，只能从5.7升级到8.0，不支持5.5,5.6直接升级到8.0。升级需要注意的问题：

原mysql5.7 mysql库下不能存在dictinary table同名的表

不支持老版本(5.6之前）的数据类型decimal，varchar, data/datetime/timestamp， 通过check table xxx for upgrade可以检测

non-native 分区表不支持

不支持5.0之前的trigger，5.0之前的trigger没有definer

foreign key constraint name 不能超过64字节

view的column不能超过255 chars

enum 类型不能超过255 chars.

frm需与InnoDB系统表一致

一些空间函数如PointFromText需修改为ST\_POINTFROMTEXT

## 10\. 参考信息

https://github.com/mysql/mysql-server

https://dev.mysql.com/doc/refman/8.0/en/data-dictionary.html

https://dev.mysql.com/doc/refman/8.0/en/system-schema.html

https://mysqlserverteam.com/upgrading-to-mysql-8-0-here-is-what-you-need-to-know/

http://mysqlserverteam.com/mysql-8-0-improvements-to-information\_schema/

https://dev.mysql.com/doc/refman/8.0/en/atomic-ddl.html

https://mysqlserverteam.com/bootstrapping-the-transactional-data-dictionary/

https://www.slideshare.net/StleDeraas/dd-and-atomic-ddl-pl17-dublin

数据和云小程序『DBASK』在线问答，随时解惑 欢迎了解和关注。

![](assets/1605168323-d7eab8d1926260c4ac2cc343856d1ecb.webp)

![](assets/1605168323-d7eab8d1926260c4ac2cc343856d1ecb.webp)

![在线问答](assets/1605168323-2103d07b2e518fe4d3bd8a69edb87bce.webp)

在线问答

![即时回复](assets/1605168323-8a23c79af0acc85cb3c21f6d7fc7e874.webp)

即时回复

资源下载

关注公众号：数据和云（OraNews）回复关键字获取

**2018DTCC, 数据库大会PPT**

**2018DTC**，2018 DTC 大会 PPT

**ENMOBK**，《Oracle性能优化与诊断案例》

**DBALIFE**，“DBA 的一天”海报

**DBA04**，DBA 手记4 电子书

**122ARCH**，Oracle 12.2体系结构图

**2018OOW**，Oracle OpenWorld 资料

产品推荐

云和恩墨zData一体机现已发布超融合版本和精简版，支持各种简化场景部署，零数据丢失备份一体机ZDBM也已发布，欢迎关注。

---------------------------------------------------


原网址: [访问](https://xw.qq.com/cmsid/20190425A01YU900)

创建于: 2020-11-12 16:05:23

目录: default

标签: `xw.qq.com`

