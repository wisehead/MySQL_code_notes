---
title: Mysql源码学习——源码目录结构 - 心中无码 - 博客园
category: default
tags: 
  - www.cnblogs.com
created_at: 2020-05-17 17:36:33
original_url: https://www.cnblogs.com/nocode/archive/2011/08/12/2135791.html
---


# Mysql源码学习——源码目录结构 - 心中无码 - 博客园

## [Mysql源码学习——源码目录结构](https://www.cnblogs.com/nocode/archive/2011/08/12/2135791.html)

2011-08-12 10:08  [心中无码](https://www.cnblogs.com/nocode/)  阅读(2967)  评论(0)  [编辑](https://i.cnblogs.com/EditPosts.aspx?postid=2135791)  [收藏](javascript:)

**Mysql源码结构**

目录清单

目录名 注释

Bdb 伯克利DB表引擎

BUILD 构建工程的脚本

Client 客户端

Cmd-line-utils 命令行工具

Config 构建工程所需的一些文件

Dbug Fred Fish的调试库

Docs 文档文件夹

Extra 一些相对独立的次要的工具

Heap HEAP表引擎

Include 头文件

Innobase INNODB表引擎

Libmysql 动态库

Libmysql_r 为了构建线程安全的libmysql库

Libmysqld 服务器作为一个嵌入式的库

Man 用户手册

Myisam MyISAM表引擎

Myisammrg MyISAM Merge表引擎

Mysql-test mysqld的测试单元

Mysys MySQL的系统库

Ndb Mysql集群

Netware Mysql网络版本相关文件

NEW-RPM 部署时存放RPM

Os2 针对OS/2操作系统的底层函数

Pstack 进行堆栈

Regex 正则表达式库（包括扩展的正则表达式函数）

SCCS 源码控制系统（不是源码的一部分）

Scripts 批量SQL脚本，如初始化库脚本

Server-tools 管理工具

Sql 处理SQL命令；Mysql的核心

Sql-bench Mysql的标准检查程序

Sql-common 一些sql文件夹相关的C文件

SSL 安全套接字层

Strings 字符串函数库

Support-files 用于在不同系统上构建Mysql的文件

Tests 包含Perl和C的测试

Tools

Vio 虚拟I/O库

Zlib 数据压缩库，用于WINDOWS

下面给出几个比较重要的目录清单：

文件清单

目录名 文件名 注释

Client

get_password.c 命令行输入密码

Mysql.cc MySQL命令行工具

Mysqladmin.cc 数据库weihu

Mysqldump.c 将表的内容以SQL语句输出，即逻辑备份

Mysqlimport.c 文本文件数据导入表中

Mysqlmanager-pwgen.c 密码生成

Mysqlshow.c 显示数据库，表和列

Mysqltest.c 被mysql测试单元使用的测试程序

\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-

MYSYS

Array.c 动态数组

Charset.c 动态字符集，默认字符集

Charset-def.c 包含客户端使用的字符集

Checksum.c 为内存块计算校验和，用于pack_isam

Default.c 从*.cnf和*.ini文件中查找默认配置项

Default_modify.c 编辑可选项

Errors.c 英文错误文本

Hash.c hash查找、比较、释放函数

List.c 双向链表

Make-conf.c 创建*.conf文件

Md5.c MD5算法

Mf_brkhant.c

Mf\_cache.c 打开临时文件,并使用io\_cache进行缓存

Mf_driname.c 解析，转换路径名

Mf\_fn\_ext.c 获取文件名的后缀

Mf_format.c 格式化文件名

Mf_getdate 获取日期：

yyyy-mm-dd hh:mm:ss format

mf_iocache.c 缓存I/O

mf_iocaches.c 多键值缓存

mf_loadpath.c 获取全路径名

mf_pack.c 创建需要的压缩/非压缩文件名

mf_path.c 决定是否程序可以找到文件

mf_qsort.c 快速排序

mf_qsort2.c 快速排序2

mf_radix.c 基数排序

mf_soundex.c 探测算法（EDN NOV 14, 1985）

mf_strip.c 去字符串结尾空格

mf_tempdir.c 临时文件夹的创建、查找、删除

mf_tempfile.c 临时文件的创建

mf_unixpath.c 转化文件名为UNIX风格

mf_util.c 常用函数

mf_wcomp.c 使用通配符比较

mf_wfile.c 通配符查找文件

mulalloc.c 同时分配多个指针

my_access.c 检查文件或路径是否合法

my_aes.c AES加密算法

my_alarm.c 警报相关

my_alloc.c 同时分配临时结果集缓存

my_append.c 一个文件到另一个

my_bit.c 除法使用，位运算

my_bitmap.c 位图

my_chsize.c 填充或截断一个文件

my_clock.c 时钟函数

my_compress.c 压缩

my_copy.c 拷贝文件

my_crc32.c

my_create.c 创建文件

my_delete.c 删除文件

my_div.c 获取文件名

my_dup.c 打开复制文件

my_error.c 错误码

my_file.c

my_fopen.c 打开文件

my_fstream.c 文件流读/写

my_gethostbyname.c 获取主机名

my_gethwaddr.c 获取硬件地址

my_getopt.c 查找生效的选项

my_getsystime.c time of day

my_getwd.c 获取工作目录

my_handler.c

my_init.c 初始化变量和函数

my_largepage.c 获取OS的分页大小

my_lib.c 比较/转化目录名和文件名

my_lock.c 锁住文件

my_lockmem.c 分配一块被锁住的内存

my_lread.c 读取文件到内存

my_lwrite.c 内存写入文件

my_malloc.c 分配内存

my_messnc.c 标准输出上输出消息

my_mkdir.c 创建目录

my_mmap.c 内存映射

my_net.c net函数

my_netware.c Mysql网络版  
my_once.c 一次分配，永不free

my_open.c 打开一个文件

my_os2cond.c 操作系统cond的简单实现

my_os2dirsrch.c 模拟Win32目录查询

my_os2dlfcn.c 模拟UNIX动态装载

my_os2file64.c 文件64位设置

my_os2mutex.c 互斥量

my_os2thread.c 线程

my_os2tls.c 线程本地存储

my_port.c

my_pthread.c 线程的封装

my_quick.c 读/写

my_read.c 从文件读bytes

my_realloc.c 重新分配内存

my_redel.c 重命名和删除文件

my_seek.c 查找

my_semaphore.c 信号量

my_sleep.c 睡眠等待

my_static.c 静态变量

my_symlink.c 读取符号链接

my_symlink2.c 2

my_sync.c 同步内存和文件

my\_thr\_init.c 初始化/分配线程变量

my_wincond.c

my_windac.c WINDOWS NT/2000自主访问控制

my_winsem.c 模拟线程

my_winthread.c 模拟线程

my_write.c 写文件

ptr_cmp.c 字节流比较函数

queue,c 优先级队列

raid2.c 支持RAID

rijndael.c AES加密算法

safemalloc.c 安全的malloc

sha1.c sha1哈希加密算法

string.c 字符串函数

testhash.c 测试哈希函数（独立程序）

test_charset 测试字符集(独立)

thr_lock.c 读写锁

thr_mutex.c 互斥量

thr_rwlock.c 同步读写锁

tree.c 二叉树

typelib.c 字符串中匹配字串

SQL  
derror.cc 读取独立于语言的信息文件

Des\_key\_file.cc 加载DES密钥

Discover.cc frm文件的查找

Field.cc 存储列信息

Filed_conv.cc 拷贝字段信息

Filesort.cc 结果集排序（内存或临时文件）

Frm\_crypt.cc get\_crypt\_from\_frm

Gen\_lex\_hash.cc 查找、排列SQL关键字

Gstream.c GIS

Handler.cc 函数句柄

Hash_filo.cc 静态大小HASH表，

以FIFO方式存储主机名、IP表

Ha_berkeley.cc BDB的句柄

Ha_innodb.cc INNODB句柄

Hostname.cc 根据IP获取hostname

Init.cc 初始化和unireg相关的函数

item.cc  item函数

item_buff.cc item的保存和比较的缓存

item_cmpfunc.cc 比较函数的定义

item_create.cc 创建一个item

item_func.cc 数字函数

item_geofunc.cc 集合函数

item_row.cc 记录项比较

item_strfunc.cc 字符串函数

item_subselect.cc 子查询

item_sum.cc 集函数（SUM,AVG...）

item_timefunc.cc 时间日期函数

item_uniq.cc  空文件

Key.cc 创建KEY以及比较

Lock.cc 锁

Log.cc 日志

log_event.cc 日志事件

Matherr.c 处理溢出

mf_iocache.cc 顺序读写的缓存

Mysqld.cc main，处理信号和连接

mf_decimal.cc decimal类型

my_lock.c

net_serv.cc socket数据包的解析

nt_servc.cc NT服务

opt_range.cc KEY排序

opt_sum.cc 集函数优化

parse_file.cc frm解析

Password.c 密码检查

Procedure.cc

Protocol.cc 数据包打包发送给客户端

protocol_cursor.cc 存储返送数据

Records.cc 读取记录集

repl_failsafe.cc

set_var.cc 设置、读取用户变量

Slave.cc slave节点

Sp.cc 存储过程和存储函数

sp_cache.cc

sp_head.cc

sp_pcontext.cc

sp_rcontext.cc

Spatial.cc 集合函数，点线面

Sql_acl.cc ACL

sql_analyse.cc

sql_base.cc 基础函数

sql_cache.cc 查询缓存

sql_client.cc

sql_crypt.cc 加解密

sql_db.cc 创建、删除DB

sql_delete.cc DELETE语句

sql_derived.cc 派生表

sql_do.cc DO

sql_error.cc  错误和警告

sql_handler.cc

sql_help.cc HELP

sql_insert.cc INSERT

sql_lex.cc 词法分析

sql_list.cc

sql_load.cc LOAD DATA 语句

sql_manager.cc 维护工作

sql_map.cc  内存映射

sql_olap.cc

sql_parse.cc 解析语句

sql_prepare.cc

sql_rename.cc 重命名table名

sql_repl.cc 复制

sql_select.cc SELECT和JOIN优化

sql_show.cc SHOW

sql_state.c 错误号和状态的映射

sql_string.cc

sql_table.cc DROP TABLE、ALTER TABLE

sql_trigger.cc 触发器

sql_udf.cc 用户自定义函数

sql_union.cc UNION操作符

sql_update.cc UPDATE

sql_view.cc 视图

Stacktrace.c 显示堆栈（LINUX/INTEL ONLY）

Strfunc.cc

Table.cc 表元数据获取（FRM）

thr_malloc.cc

Time.cc

Uniques.cc 副本的快速删除

Unireg.cc 创建一个FRM

更多内容请参考：

[http://forge.mysql.com/wiki/MySQL\_Internals\_Files\_In\_MySQL\_Sources#The\_sql_Directory](http://forge.mysql.com/wiki/MySQL_Internals_Files_In_MySQL_Sources#The_sql_Directory)

踏着落叶，追寻着我的梦想。转载请注明出处

*   分类 [MySQL Code Trace](https://www.cnblogs.com/nocode/category/293180.html)

---------------------------------------------------


原网址: [访问](https://www.cnblogs.com/nocode/archive/2011/08/12/2135791.html)

创建于: 2020-05-17 17:36:33

目录: default

标签: `www.cnblogs.com`

