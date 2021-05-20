# InnoDB Memcached Plugin源码实现调研

![](assets/1621491781-c5f6fc06f17ef40a2695561e87a02f38.png)

[hjxhjh](https://blog.csdn.net/hjxhjh) 2013-07-10 19:29:52 ![](assets/1621491781-11d4e66b47a786d7307438a15382d44a.png) 870 ![](assets/1621491781-50c7c045de1e4400c6f27a33ed55cf7c.png) 收藏 

分类专栏： [C/C++](https://blog.csdn.net/hjxhjh/category_783335.html)

MySQL 5.6版本，新增了一个NoSQL的接口，通过将memcached嵌入到MySQL系统之中，用户可以直接使用memcached接口直接操作MySQL中的InnoDB表，绕过MySQL Server层面的SQL解析，优化，甚至绕过InnoDB Handler层，直接操作InnoDB内部的方法，从而达到更优的响应时间与效率。关于此功能的官方介绍，请见：[InnoDB Integration with memcached](http://dev.mysql.com/doc/refman/5.6/en/innodb-memcached.html) 。嵌入memcached之后，整个MySQL的架构如下图所示：

![](assets/1621491781-b569c61de687dfd3c776edd316b0b484.jpg)

本文接下来的部分，将从源码的角度，详细分析InnoDB Integration with memcached的实现细节问题。

# 导读  

*   InnoDB引擎为了支持Memcached API，在Handler层面进行的改动，请见**(一)**；
    

  

*   Memcached Plugin的初始化流程，请见**(二)**；
    

*   InnoDB提供的Callback方法在InnoDB Handlerton中的data中以及Memcached Plugin的data中，是如何传递的呢？请见**(三)**；
    

*   InnoDB Memcached Engine提供的方法集合，请见**(四)**；
    

*   InnoDB Memcached Engine提供的方法，如何调用到InnoDB Engine提供的方法，请见**(五)**；
    

*   InnoDB Memcached Engine中，存在两个Engine实例：InnoDB Engine vs Default Engine，二者的功能异同，请见**(六)**；
    

*   InnoDB Memcached Engine中，需要配置Container Table，Container表详解，请见**(七)**；
    

*   InnoDB Memcached Engine的初始化与使用流程，可参考engine\_testapp.c测试文件；
    

# (一) InnoDB Handler层面改动  

InnoDB为了支持Memcached接口，在其Handler层面提供了新的Callback方法，这些方法的定义如下：

/\*\* Set up InnoDB API callback function array \*/  

 ib\_cb\_t innodb\_api\_cb\[\] = {

 (ib\_cb\_t) ib\_cursor\_open\_table,

 (ib\_cb\_t) ib\_cursor\_read\_row,

 (ib\_cb\_t) ib\_cursor\_insert\_row,

 (ib\_cb\_t) ib\_cursor\_delete\_row,

 (ib\_cb\_t) ib\_cursor\_update\_row,

 (ib\_cb\_t) ib\_cursor\_next,

 (ib\_cb\_t) ib\_cursor\_last,

 (ib\_cb\_t) ib\_tuple\_get\_n\_cols,

 (ib\_cb\_t) ib\_col\_set\_value,

 (ib\_cb\_t) ib\_col\_get\_value,

 (ib\_cb\_t) ib\_col\_get\_meta,

 (ib\_cb\_t) ib\_trx\_begin,

 (ib\_cb\_t) ib\_trx\_commit,

 (ib\_cb\_t) ib\_trx\_rollback,

 (ib\_cb\_t) ib\_trx\_start,

 …

 };

同时，innodb\_api\_cb\[\]数组，被存储在InnoDB Handlerton的data字段中，可以向上传递给InnoDB Memcached Engine。InnoDB Memcached Engine可以调用这些Callback方法，达到直接操作InnoDB Engine的目的。

ha\_innodb.cc::innobase\_init();  

 …

 innobase\_hton->data = &innodb\_api\_cb;

# (二) Memcached Plugin的初始化流程  

Memcached Plugin，同样注册为MySQL的一个插件(memcached\_mysql.cc)，此插件的定义如下：

mysql\_declare\_plugin(daemon\_memcached)  

 {

 MYSQL\_DAEMON\_PLUGIN,

 &daemon\_memcached\_plugin,

 ”daemon\_memcached”,

 ”Oracle Corporation”,

 ”Memcached Daemon”,

 PLUGIN\_LICENSE\_GPL,

 daemon\_memcached\_plugin\_init,        /\* Plugin Init \*/

 daemon\_memcached\_plugin\_deinit,    /\* Plugin Deinit \*/

 0×0100                                                            /\* 1.0 \*/,

 NULL,                                                               /\* status variables \*/

 daemon\_memcached\_sys\_var,              /\* system variables \*/

 NULL                                                                /\* config options \*/

 }

 mysql\_declare\_plugin\_end;

Memcached Plugin插件，初始化为daemon\_memcached\_plugin\_init函数，该函数同样需要一个Handlerton输入，初始化Memcached Plugin插件，尤其是初始化InnoDB Memcached Engine。详细的初始化流程如下所示:

struct mysql\_memcached\_context \* con;  

  

 // plugin为InnoDB的Handlerton，plugin->data指向InnoDB Handlerton中的data，

 // 在InnoDB的init函数中被初始化为innodb\_api\_cb数组。innodb\_api\_cb数组中，

 // 注册了各种InnoDB提供的方法。

 …

 con->memcached\_conf.m\_innodb\_api\_cb = plugin->data;

 …

  

 // 创建Memcached Plugin后台线程，线程的主函数为daemon\_memcached\_main()，

 // 线程传入参数，即为从InnoDB Handlerton处获取的InnoDB提供的Callback方法

 pthread\_create(&con->memcached\_thread, &attr,

 daemon\_memcached\_main, (void \*)&con->memcached\_conf);

 …

 // 创建、加载InnoDB Memcached Engine

 Engine\_loader.c::load\_engine();

 // Create InnoDB Memcached Engine

 // 注册InnoDB Memcached Engine的各种方法，例如：

 // 初始化方法：innodb\_eng->engine.initialize = innodb\_initialize;

 innodb\_engine.c::create\_instance();

 …

 // 初始化InnoDB Memcached Engine

 Engine\_loader.c::init\_engine(engine\_handle,engine\_config…);

 Innodb\_engine.c::innodb\_initialize(engine, config\_str);

 // 注册InnoDB Engine提供的内部方法至InnoDB Memcached Engine，

 // 包括：读取、插入、删除、更新、事务创建/提交/回滚等操作。

 // 至此，后续的InnoDB Memcached Engine的所有操作，均可被映射

 // 为InnoDB Storage Engine提供的内部方法进行实际操作。

 Innodb\_api.c::register\_innodb\_cb();

 // Fetch InnoDB specific settings

 innodb\_eng->meta\_info = innodb\_config(NULL, 0, &innodb\_eng->meta\_hash);

 // Find the table and column info that used for memcached data

 // Cantainers表：InnoDB内部存储元数据的系统表，

 // MCI\_CFG\_DB\_NAME；MCI\_CFG\_CONTAINER\_TABLE；…

 innodb\_config.c::innodb\_config\_container();

 …

 // 开启InnoDB Memcached Engine的后台自动提交线程

 innodb\_engine.c::innodb\_bk\_thread();

 …

 …

  

 // 在InnoDB Handlerton中存储更多Memcached Plugin所需要的信息

 plugin->data = (void \*)con;

# (三) Memcached Plugin如何获取使用InnoDB Handlerton中的innodb\_api\_cb？  

// 在此函数中完成innodb\_api\_cb的传递  

sql\_plugin.cc::plugin\_initialize();  

 // 此函数指针，直接调用到Plugin注册的init方法

 (\*plugin\_type\_initialize\[plugin->plugin->type\])(plugin);

 …

 // 判断出当前是InnoDB引擎完成了初始化，则将InnoDB Handlerton中

 // 的data拷贝到临时变量中

 if (strcmp(plugin->name.str, “InnoDB”) == 0)

 innodb\_callback\_data = ((Handlerton \*)plugin->data)->data;

 // 判断出当前Plugin为Memcached Plugin，则将临时变量赋值到memcached plugin

 // 的data中，完成InnoDB Handlerton提供的Callback方法的传递

 else if (plugin->plugin->init)

 if (strcmp(plugin->name.str, “daemon\_memcached”) == 0)

 plugin->data = (void \*)innodb\_callback\_data;

 // 初始化Memcached Plugin

 plugin->plugin->init();

# (四) InnoDB Memcached Plugin提供的方法集合  

innodb\_engine.c::create\_instance();  

 innodb\_eng->engine.interface.interface = 1;

 innodb\_eng->engine.get\_info = innodb\_get\_info;

 innodb\_eng->engine.initialize = innodb\_initialize;

 innodb\_eng->engine.destroy = innodb\_destroy;

 innodb\_eng->engine.allocate = innodb\_allocate;

 innodb\_eng->engine.remove = innodb\_remove;

 innodb\_eng->engine.release = innodb\_release;

 innodb\_eng->engine.clean\_engine= innodb\_clean\_engine;

 innodb\_eng->engine.get = innodb\_get;

 innodb\_eng->engine.get\_stats = innodb\_get\_stats;

 innodb\_eng->engine.reset\_stats = innodb\_reset\_stats;

 innodb\_eng->engine.store = innodb\_store;

 innodb\_eng->engine.arithmetic = innodb\_arithmetic;

 innodb\_eng->engine.flush = innodb\_flush;

 innodb\_eng->engine.unknown\_command = innodb\_unknown\_command;

 innodb\_eng->engine.item\_set\_cas = item\_set\_cas;

 innodb\_eng->engine.get\_item\_info = innodb\_get\_item\_info;

 innodb\_eng->engine.get\_stats\_struct = NULL;

 innodb\_eng->engine.errinfo = NULL;

 innodb\_eng->engine.bind = innodb\_bind;

所有InnoDB Memcached Engine提供的方法，都是类Memcached方法。例如：get/remove/store方法等。

# (五) 一个InnoDB Memcached Plugin的操作的流程  

通过Memcached Plugin进行一个删除操作的函数处理流程，如下：

注1：删除操作，对应的InnoDB Handlerton提供的方法为：    remove()

注2：删除操作，对应的InnoDB Memcached Engine的方法为：    ib\_cursor\_delete\_row()

// 通过Memcached接口删除操作的处理流程  

memcached.c::process\_delete\_command();  

 settings.engine.v1->remove(settings.engine.v0, c, key, nkey, 0, 0);

 // InnoDB Memcached Engine层面提供的删除方法

 innodb\_engine.c::innodb\_remove(ENGINE\_HANDLE\*, cookie, key, nkey, …);

 …

 // 初始化InnoDB的连接，传入参数分析：

 // CONN\_MODE\_WRITE：当前为写操作

 // IB\_LOCK\_X：        当前操作需要对记录行加X锁

 conn\_data = innodb\_conn\_init(innodb\_eng, cookie, CONN\_MODE\_WRITE, …);

 if (conn\_option == CONN\_MODE\_WRITE)

 // 开始一个事务

 innodb\_api.c::innodb\_cb\_trx\_begin();

 ib\_cb\_trx\_begin() -> api0api.cc::ib\_trx\_begin();

 // 打开当前表，并设置游标

 innodb\_api.c::innodb\_api\_begin();

 …

 // 进行真正的删除操作

 innodb\_api.c::innodb\_api\_delete(innodb\_eng, conn\_data, key, nkey);

 // 根据传入的key，将游标定位到正确的位置

 innodb\_api.c::innodb\_api\_search();

 …

 // 如果开启了binlog，则需要将定位到的记录拷贝出来

 if (engine->enable\_binlog)

 …

 // 删除记录

 ib\_cb\_delete\_row() -> api0api.cc::ib\_cursor\_delete\_row();

  

 // 记录binlog

 handler\_api.cc::handler\_binlog\_row();

  

 // 删除构造出来的Tuple对象

 ib\_cb\_tuple\_delete() -> api0api.cc::ib\_tuple\_delete();

# (六) InnoDB Engine vs Default Engine  

在InnoDB Engine结构的内部(innodb\_engine.h::struct innodb\_engine)，有两个实例化的Engine Handle，分别为：

ENGINE\_HANDLE\_V1    engine;  

 ENGINE\_HANDLE\*        default\_engine;

两个engine handle有何区别：

*   ENGINE\_HANDLE\_V1为InnoDB Engine Handle，封装了所有InnoDB引擎提供的方法；  
    

*   ENGINE\_HANDLE(default\_engine)为Memcached自带的默认Engine，封装了所有标准Memcached所提供的方案，包括：slab分配，数据的存取、失效等等。  
    

*   InnoDB Engine与Default Engine是否启用？是否同时启用？通过参数控制：  
    

/\*\* Tells if we will used Memcached default engine or InnoDB Memcached engine to handle the request \*/  

 typedef enum meta\_cache\_opt {

 META\_CACHE\_OPT\_INNODB = 1,        /\*!< Use InnoDB Memcached Engine only \*/

 META\_CACHE\_OPT\_DEFAULT,             /\*!< Use Default Memcached Engine only \*/

 META\_CACHE\_OPT\_MIX,                        /\*!< Use both, first use default memcached engine \*/

 META\_CACHE\_OPT\_DISABLE,               /\*!< This operation is disabled \*/

 META\_CACHE\_NUM\_OPT                        /\*!< Number of options \*/

 } meta\_cache\_opt\_t;

默认的参数值为META\_CACHE\_OPT\_INNODB，仅仅启用InnoDB Engine，数据通过InnoDB引擎提供的Callback方法操作；若同时启用了Memcached Default Engine(META\_CACHE\_OPT\_MIX)，那么数据读取时，首先从Default Engine中读取；记录删除时，也需要先删除Default Engine中的记录；

# (七) Container表详解  

InnoDB Memcached Engine，包含一个Container Table，用于存储Memcached与InnoDB Table之间的映射关系。

Container Table，必须包含9列，分别是：

/\*\* Columns in the “containers” system table, this maps the Memcached  

 operation to a consistent InnoDB table \*/

 typedef enum container {

 CONTAINER\_NAME,         /\*!< name for this mapping \*/

 CONTAINER\_DB,                /\*!< database name \*/

 CONTAINER\_TABLE,        /\*!< table name \*/

 CONTAINER\_KEY,             /\*!< column name for column maps to    memcached “key” \*/

 CONTAINER\_VALUE,       /\*!< column name for column maps to    memcached “value” \*/

 CONTAINER\_FLAG,          /\*!< column name for column maps to    memcached “flag” value \*/

 CONTAINER\_CAS,             /\*!< column name for column maps to    memcached “cas” value \*/

 CONTAINER\_EXP,             /\*!< column name for column maps to “expiration” value \*/

 CONTAINER\_NUM\_COLS    /\*!< number of columns \*/

 } container\_t;

其中：

*   CONTAINER\_TABLE为InnoDB表名，CONTAINER\_DB为对应的Database名；
    
      
    
*   CONTAINER\_KEY为Memcached的Key对应的InnoDB表中的列名(只能一列)；  
    
      
    
*   CONTAINER\_VALUE为Memcached的Value对应的InnoDB表中的列名(可以有多列，以” ;,|  
    ”作为分隔符，详见innodb\_config.c::innodb\_config\_parse\_value\_col()函数)；  
    
      
    
*   CONTAINER Table的最后一列，为CONTAINER\_KEY列对应的InnoDB表的唯一索引名(必须存在)；  
    
      
    
*   CONTAINER Table，在innodb\_engine.cc::innodb\_initialize函数被读取，将其中的每一项都解析并存储到InnoDB Engine的meta\_hash结构之中：  
    

innodb\_config.c::innodb\_config(NULL, 0, &innodb\_eng->meta\_hash);  

 innodb\_config\_meta\_hash\_init();

 …

 // 打开CONTAINER Table

 innodb\_api.c::innodb\_api\_begin(…, MCI\_CFG\_CONTAINER\_TABLE, …);

 innodb\_api.c::innodb\_cb\_read\_row();

 innodb\_config.c::innodb\_config\_add\_item();

 …

 // 针对Value列，需要解析此列对应于InnoDB Table的哪些列

 // InnoDB中的不同列，以” ;,|  
”作为分隔符

 if (i == CONTAINER\_VALUE)

 innodb\_config\_parse\_value\_col();

 …

在innodb\_engine.cc::innodb\_initialize函数，完成Container Table的读取以及Meta Hash的填充之后，后续的Memcached方法，才可以根据规则操作，完成记录在Memcached与InnoDB引擎间的传递。

转自：[http://ourmysql.com/archives/1255](http://ourmysql.com/archives/1255)