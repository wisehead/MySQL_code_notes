MySQL定义了一系列抽象存储引擎API，以支持插件式存储引擎架构。在历史版本中，这些接口被为"table handler"。我们这里所说的存储引擎（Storage Engine），是指数据的存储/读取相关的逻辑模块。而存储引擎API（table handler）是指Storage Engine与MySQL优化器间的接口。比如，新增一个存储引擎---Storage Engine，如何实现MySQL服务层对存储存储引擎访问呢？MySQL服务访问的存储引擎是接口就是抽象存储引擎API，新存储引擎只需要实现相应的抽象存储引擎API接口，就可以实现MySQL Service对存储引擎的访问。
MySQL插件式存储引擎架构，促使MySQL以更加开放的姿态，接受更多的存储引擎。抽象存储引擎接口是在v3.22提升到v3.23时引入的设计。在快速集成InnoDB存储引擎阶段中起了很大的作用。众所周知，InnoDB为MySQL带来了稳定事务支持、多版本、行锁。只要知道怎么读写记录，任何东西都可以很快的集成到MySQL中。
抽象存储引擎API接口是通过抽象类handler来实现，handler类提供诸如打开/关闭table、扫表、查询Key数据、写记录、删除记录等基础操作方法。每一个存储引擎通过继承handler类，实现以上提到的方法，在方法里面实现对底层存储引擎的读写接口的转调。从5.0版本开始，为了避免在初始化、事务提交、保存事务点、回滚操作时需要操作one-table实例，引入了handlerton结构让存储引擎提供了发生上面提到操作时的钩子操作。



API以Handler类的虚函数的方式存在，可在代码库下的./sql/handler.h中查看详细信息。可在Handler类的注释中看到描述：

```cpp
/**
  The handler class is the interface for dynamically loadable
  storage engines. Do not add ifdefs and take care when adding or
  changing virtual functions to avoid vtable confusion
  Functions in this class accept and return table columns data. Two data
  representation formats are used:
  1. TableRecordFormat - Used to pass [partial] table records to/from
     storage engine
  2. KeyTupleFormat - used to pass index search tuples (aka "keys") to
     storage engine. See opt_range.cc for description of this format.
  TableRecordFormat
  =================
  [Warning: this description is work in progress and may be incomplete]
  The table record is stored in a fixed-size buffer:
    record: null_bytes, column1_data, column2_data, ...
  //篇幅原因，略去部分内容。
*/
class handler : public Sql_alloc
{
    //篇幅原因，不列出具体代码。读者可直接在源码文件./sql/handler.h中找到具体内容。
}
```

Handler类继承自Sql_alloc类，Sql_alloc没有任何成员变量，纯粹重载了new和delete操作。所以Handler类分配内存是可以从连接相关的内存池来分配。而delete操作时不做任何事情。内存的释放只会在mysys/my_alloc.c的free_root()调用发生。无需显式释放，在语句执行之后清理。

每一个table描述符对应一个handler的实例。注意针对同一个table可能会被打开多次的情况，这时候会出现多个handler实例。5.0版本引入index_merge方法后导致了一些有趣的方式，以前多个handler实例只会在table cache中拷贝描述符产生，引入Index_merge之后，handler实例可能会在优化阶段被创建。
下面我将分类描述部分存储引擎API。
创建、打开和关闭表：

通过函数create来创建一个table：

```cpp
/**
  *name：要创建的表的名字
  *from：一个TABLE类型的结构，要创建的表的定义，跟MySQL Server已经创建好的tablename.frm文件内容是匹配的
  *info：一个HA_CREATE_INFO类型的结构，包含了客户端输入的CREATE TABLE语句的信息
*/
int create(const char *name, TABLE *form, HA_CREATE_INFO *info);
```

通过函数open来打开一个table：

```cpp
/**
  mode包含以下两种
  O_RDONLY  -  Open read only
  O_RDWR    -  Open read/write
*/
int open(const char *name, int mode, int test_if_locked);
```

通过函数close来关闭一个table：
int close(void);


对表加锁：
当客户端调用LOCK TABLE时，通过external_lock函数加锁：

```cpp
int ha_example::external_lock(THD *thd, int lock_type)
```

全表扫描：

```cpp
//初始化全表扫描
virtual int rnd_init (bool scan);
//从表中读取下一行
virtual int rnd_next (byte* buf);
```

通过索引访问table内容

```cpp
//使用索引前调用该方法
int ha_foo::index_init(uint keynr, bool sorted) 
//使用索引后调用该方法
int ha_foo::index_end(uint keynr, bool sorted)
//读取索引第一条内容
int ha_index_first(uchar * buf);
//读取索引下一条内容
int ha_index_next(uchar * buf);
//读取索引前一条内容
int ha_index_prev(uchar * buf);
//读取索引最后一条内容
int ha_index_last(uchar * buf);
//给定一个key基于索引读取内容
int index_read(uchar * buf, const uchar * key, uint key_len,
          enum ha_rkey_function find_flag)
事务处理
//开始一个事务
int my_handler::start_stmt(THD *thd, thr_lock_type lock_type)
//回滚一个事务
int (*rollback)(THD *thd, bool all); 
//提交一个事务
int (*commit)(THD *thd, bool all);
```


handlerton 4.1之前的版本，从handler类继承是唯一一个存储引擎可以与核心结构交互的途径。
当优化器需要针对存储引擎做一些事情的时候，只可能调用当前table相关的handler实例的接口方法。但是随着集成多种存储引擎的发展，尽是靠handler方法来交互的形式是不太够的，因此，handlerton概念诞生。

handlerton是一个几乎全是回调方法指针的C结构体。定义在sql/handler.h
回调函数在某一事件发生时针对具体的存储引擎被调用(事务提交/保存事务点/连接关闭等)


如何编写自己的存储引擎
在MySQL的官方文档上，有对于编写自己的存储引擎的指导文档，链接如下。
作为编写自己存储引擎的开始，你可以查看MySQL源码库中的一个EXAMPLE存储引擎，它实现了必须要实现的存储引擎API，可以通过复制它们作为编写我们自己存储引擎的开始：

sed -e s/EXAMPLE/FOO/g -e s/example/foo/g ha_example.h > ha_foo.h
sed -e s/EXAMPLE/FOO/g -e s/example/foo/g ha_example.cc > ha_foo.cc



如何添加第三方存储引擎

5.1之后版本添加变得简单多。可以根据"blackhole"存储引擎的模式来改造
1、创建目录 storage/xx-csv,实际文件ha_csv.h(cc)移至该目录
2、Makefile.am 放入storage/xx-csv
3、configure.in 改写MYSQL_STORAGE_ENGINE宏
4、autoconf & automake & ./configure --prefix=/usr --with-plugins=xx-csv & make

mysql_declare_plugin宏注册引擎

读写支持的存储引擎需要面对更多问题，多个handler实例会被创建，发现多个写实例的存在会导致写入位置发生一些奇怪的现象，这或许会让我们感到惊讶。其他存储引擎通过共享底层的表描述符结构体来解决这个问题。

sql/examples/ha_tina.cc更为详细的引擎实现方式
