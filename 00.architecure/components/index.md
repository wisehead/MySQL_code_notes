---
title: mysql 源代码目录及安装目录介绍 - 张冲andy - 博客园
category: default
tags: 
  - www.cnblogs.com
created_at: 2020-05-16 21:20:44
original_url: https://www.cnblogs.com/andy6/p/5789245.html
---


# mysql 源代码目录及安装目录介绍 - 张冲andy - 博客园

**1、源代码目录介绍：**

1、BUILD  
    BUILD目录是编译、安装脚本目录，绝大部分以compile-开头，其中的SETUP.sh脚本为C和C++编译器设置了优化选项。  
2、client  
    client目录包括常用命令和客户端工具代码，这些源代码文件中包括密码确认功能get_password.c、SSL连接可行性检查、MySQL客户端mysql.cc、mysqladmin工具和mysqladmin用于服务器的运作mysqladmin.c、显示数据库及其表和列的mysqlshow.c等。  
3、storage  
    MySQL的各类存储引擎代码都在该目录中，包括CVS存储引擎（cvs目录）、InnoDB存储引擎、Federate等。存储引擎是数据库系统的核心，封装了数据库文件的操作，是数据库系统是否强大最重要的因素。Mysql实现了一个抽象接口层，叫做 handler(sql/handler.h)，其中定义了接口函数，比如：ha\_open, ha\_index\_end, ha\_create等等，存储引擎需要实现这些接口才能被系统使用。这个接口定义超级复杂，有900多行 :-(，不过我们暂时知道它是干什么的就好了，没必要深究每行代码。对于具体每种引擎的特点，我推荐大家去看mysql的在线文档: http://dev.mysql.com/doc/refman/5.1/en/storage-engines.html   

应该能看到如下的目录:    
\* innobase, innodb的目录，当前最流行的存储引擎    
\* myisam, 最早的Mysql存储引擎,一直到innodb出现以前，使用最广的引擎  
\* heap, 基于内存的存储引擎    
\* federated, 一个比较新的存储引擎    
\* example, csv，这几个大家可以作为自己写存储引擎时的参考实现，比较容易读懂

  
4、mysys  
    mysys代表MySQL system library，是MySQL的库函数文件。库函数是一些预先编译好的函数的集合，这些函数都是按照可再使用的原则编写的。它们通常由一组互相关联的用来完成某项常见的工作的函数构成，从本质上来说库是一种可执行的二进制形式，可以被操作系统载入内存执行。在mysys目录中，共有125个.c文件，且随着版本的演化和新功能的加入，库函数也在不断的增大。  
    其中包括用于快速排序的mf\_qsort.c、用于临时文件管理的mf\_tempfile.c、定义在客户端编译时采用字符集类型的charset-def.c、字符集相关操作（字符集加载、初始化等）的charset.c。  
    mysys是一个大杂烩，包含了各种各样的功能库文件，包括文件打开、数据读写、内存分配、OS/2系统特别优化、线程控制、权限控制、RaidTable、动态字符串处理、队列算法、网络传输协议、初始化函数、错误处理、平衡二叉树算法、符号连接处理、唯一临时文件名生成、hash函数、排序算法、压缩传输协议等。

  
5、sql  
    sql目录出了包含mysqld.cc这一MySQL main函数（没错，这里就是数据库主程序mysqld所在的地方，大部分的系统流程都发生在这里。）所在的文件外，还包括了各类SQL语句的解析/实现、线程、查询解析与查询优化器、存储引擎接口（你还能看到sql\_insert.cc, sql\_update.cc, sql_select.cc，等等，分别实现了对应的SQL命令。后面我们还要经常提到这个目录下的文件）。在storage下各存储引擎目录中，存在的是各类存储引擎的实现代码，而在sql/目录下存放的是处理接口handler。handler类中存在很多虚函数，需要其子类进行实现  
    如今在MySQL 5.1中，综合文件hadler.cc和handler.h处理了所有不同种类存储请求。各种SQL语句的执行代码也可以在sql目录中找到，这类文件常以sql开始对文件命名。MySQL将UNION和ROLLUP等操作看作内部函数。

大概有如下及部分:    
SQL解析器代码: sql\_lex.cc, sql\_yacc.yy, sql\_yacc.cc, sql\_parse.cc等，实现了对SQL语句的解析操作。    
"handler"代码: handle.cc, handler.h，定义了存储引擎的接口。    
"item"代码：item\_func.cc, item\_create.cc，定义了SQL解析后的各个部分。    
SQL语句执行代码: sql\_update.cc, sql\_insert.cc sql\_select.cc, sql\_show.cc, sql\_load.cc，执行SQL对应的语句。当你要看"SELECT ..."的执行的时候，直接到sql\_select.cc去看就OK了。    
辅助代码: net_serv.cc实现网络操作    
还有其他很多代码。

  
6、vio  
    VIO意指Virtual I/O，主要用来处理各种网络协议的IO。Virtual I/O使得各种模块的网络协议能够无缝的调用I/O功能。MySQL网络子系统将调用这里的方法。  
7、regex  
    regex为MySQL提供执行正则匹配函数REGEXP时的支持。  
8、dbug  
    使用with-debug参数编译的MySQL会显示dbug输出，代码中的所有.c和.cc文件均可调用这个库。

**2、安装目录介绍：**


