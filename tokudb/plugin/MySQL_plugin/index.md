---
title: Mysql源代码分析(5): Plugin架构介绍--转载 - 风生水起 - 博客园
category: default
tags: 
  - www.cnblogs.com
created_at: 2020-05-15 16:20:31
original_url: https://www.cnblogs.com/end/archive/2011/05/18/2050288.html
---


# Mysql源代码分析(5): Plugin架构介绍--转载 - 风生水起 - 博客园

[Mysql源代码分析(5): Plugin架构介绍--转载](https://www.cnblogs.com/end/archive/2011/05/18/2050288.html)

Mysql现在很多模块都是通过plugin的方式连接到 Mysql核心中的，除了大家熟悉的存储引擎都是Plugin之外，Mysql还支持其他类型的plugin。本文将对相关内容做一些简单介绍。主要还是 以架构性的介绍为主，具体细节会提到一点，但是肯定不会包括所有的细节。

### 主要数据结构和定义

大部分的数据接口，宏和常量都定义在include/mysql/plugin.h中，我们来慢慢看。

先看plugin的类型:

```cpp
#define MYSQL\_UDF\_PLUGIN 0 /* User-defined function */

#define MYSQL\_STORAGE\_ENGINE_PLUGIN 1 /* Storage Engine */

#define MYSQL\_FTPARSER\_PLUGIN 2 /* Full-text parser plugin */

#define MYSQL\_DAEMON\_PLUGIN 3 /* The daemon/raw plugin type */

#define MYSQL\_INFORMATION\_SCHEMA\_PLUGIN 4 /* The I\_S plugin type */
```

开发者开发的plugin必须指定上述类型之一。 类型包括用户自定义函数，存储引擎，全文解析，原声plugin和information schema plugin。最常见的是前三个，daemon plugin一般用来在mysqld中启动一个线程，在某些时候干活儿。

一个plugin的描述数据接口是：

```cpp
struct st\_mysql\_plugin

{

   int type; /* the plugin type (a MYSQL\_XXX\_PLUGIN value) */

   void \*info; /\* pointer to type-specific plugin descriptor */

   const char \*name; /\* plugin name */

   const char \*author; /\* plugin author (for SHOW PLUGINS) */

   const char \*descr; /\* general descriptive text (for SHOW PLUGINS ) */

   int license; /* the plugin license (PLUGIN\_LICENSE\_XXX) */

   int (\*init)(void \*); /* the function to invoke when plugin is loaded */

   int (\*deinit)(void \*);/* the function to invoke when plugin is unloaded */

   unsigned int version; /* plugin version (for SHOW PLUGINS) */

   struct st\_mysql\_show\_var *status\_vars;

   struct st\_mysql\_sys\_var **system\_vars;

   void * __reserved1; /* reserved for dependency checking */

};
```

主要内容包括类型，名字，初始化/清理函数，状态变量和系统变量的定义等等。但是在使用的时候一般不是直接使用这个数据结构，而是使用大量的宏来辅助。

一个plugin的开始：

```cpp
#define mysql\_declare\_plugin(NAME) \

\_\_MYSQL\_DECLARE_PLUGIN(NAME, \

   builtin_ ## NAME ## \_plugin\_interface_version, \

   builtin_ ## NAME ## \_sizeof\_struct\_st\_plugin, \

   builtin_ ## NAME ## _plugin)
```   

plugin定义结束：

```cpp
#define mysql\_declare\_plugin_end ,{0,0,0,0,0,0,0,0,0,0,0,0}}
```

\_\_MYSQL\_DECLARE_PLUGIN根据plugin是动态链接plugin还是静态链接plugin有不同的定义：

```cpp

#ifndef MYSQL\_DYNAMIC\_PLUGIN

#define \_\_MYSQL\_DECLARE_PLUGIN(NAME, VERSION, PSIZE, DECLS) \

int VERSION= MYSQL\_PLUGIN\_INTERFACE_VERSION; \

int PSIZE= sizeof(struct st\_mysql\_plugin); \

struct st\_mysql\_plugin DECLS\[\]= {

#else

#define \_\_MYSQL\_DECLARE_PLUGIN(NAME, VERSION, PSIZE, DECLS) \

int \_mysql\_plugin\_interface\_version_= MYSQL\_PLUGIN\_INTERFACE_VERSION; \

int \_mysql\_sizeof\_struct\_st\_plugin\_= sizeof(struct st\_mysql\_plugin); \

struct st\_mysql\_plugin \_mysql\_plugin\_declarations\_\[\]= {

#endif
```

特别要注意的是“#ifndef MYSQL\_DYNAMIC\_PLUGIN”，如果你要写的plugin是动态加载的话，需要在编译的时候定义这个宏。

总体而 言，mysql\_declare\_plugin申明了一个struct st\_mysql\_plugin数组，开发者需要在该宏之后填写plugin自定义的st\_mysql\_plugin各个成员，并通过 mysql\_declare\_plugin_end结束这个数组。

看个例子 plugin/daemon\_example/daemon\_example.cc，这是个动态MYSQL\_DAEMON\_PLUGIN类型的 plugin，注意到plugin/daemon\_example/Makefile.am里面有-DMYSQL\_DYNAMIC_PLUGIN。具体定 义如下：

```cpp
mysql\_declare\_plugin(daemon_example)

{

   MYSQL\_DAEMON\_PLUGIN,

   &daemon\_example\_plugin,

   "daemon_example",

   "Brian Aker",

   "Daemon example, creates a heartbeat beat file in mysql-heartbeat.log",

   PLUGIN\_LICENSE\_GPL,

   daemon\_example\_plugin_init, /* Plugin Init */ // plugin初始化入口

   daemon\_example\_plugin_deinit, /* Plugin Deinit */    // plugin清理函数

   0x0100 /* 1.0 */,

   NULL, /* status variables */

   NULL, /* system variables */

   NULL /* config options */

}

mysql\_declare\_plugin_end;
```

这个定义经过preprocess被展开后定义为：

```
int \_mysql\_plugin\_interface\_version_= MYSQL\_PLUGIN\_INTERFACE_VERSION; \

int \_mysql\_sizeof\_struct\_st\_plugin\_= sizeof(struct st\_mysql\_plugin); \

struct st\_mysql\_plugin \_mysql\_plugin\_declarations\_\[\]= {

   { MYSQL\_DAEMON\_PLUGIN,

   &daemon\_example\_plugin,

   "daemon_example",

   "Brian Aker",

   "Daemon example, creates a heartbeat beat file in mysql-heartbeat.log",

   PLUGIN\_LICENSE\_GPL,

   daemon\_example\_plugin_init, /* Plugin Init */ // plugin初始化入口

   daemon\_example\_plugin_deinit, /* Plugin Deinit */    // plugin清理函数

   0x0100 /* 1.0 */,

   NULL, /* status variables */

   NULL, /* system variables */

   NULL /* config options */

} , {0,0,0,0,0,0,0,0,0,0,0,0}};
```

静态链接plugin也类似，只不过plugin宏展开出来的变量都有自己的名字，对于myisam，生成了一个叫builtin\_myisam\_plugin的plugin数组。

plugin可以定义自己的变量，包括系统变量和状态变量。具体的例子可以看看storage/innobase/handler/ha_innodb.cc里面对于innodb插件的申明，结合plugin.h，还是比较容易看懂的。

在mysql的源代码里面grep一把mysql\_declare\_plugin，看看都有哪些plugin:

```
$grep "mysql\_declare\_plugin(" --include=*.cc -rni *

plugin/daemon\_example/daemon\_example.cc:187:mysql\_declare\_plugin(daemon_example)

sql/ha\_partition.cc:6269:mysql\_declare_plugin(partition)

sql/log.cc:5528:mysql\_declare\_plugin(binlog)

sql/ha\_ndbcluster.cc:10533:mysql\_declare_plugin(ndbcluster)

storage/csv/ha\_tina.cc:1603:mysql\_declare_plugin(csv)

storage/example/ha\_example.cc:893:mysql\_declare_plugin(example)

storage/myisam/ha\_myisam.cc:2057:mysql\_declare_plugin(myisam)

storage/heap/ha\_heap.cc:746:mysql\_declare_plugin(heap)

storage/innobase/handler/ha\_innodb.cc:8231:mysql\_declare_plugin(innobase)

storage/myisammrg/ha\_myisammrg.cc:1186:mysql\_declare_plugin(myisammrg)

storage/blackhole/ha\_blackhole.cc:356:mysql\_declare_plugin(blackhole)

storage/federated/ha\_federated.cc:3368:mysql\_declare_plugin(federated)

storage/archive/ha\_archive.cc:1627:mysql\_declare_plugin(archive)
```

呵呵，连binlog都是plugin哦，不过还是storage plugin占大多数。

Plugin初始化

  

在见面的介绍main函数的文章中我也提到了其中有个函数plugin\_init()是初始化的一部分，这个东东就是所有静态链接初始化plugin的初始化入口。该函数定义在"sql/sql\_plugin.cc"中。

```cpp
int plugin_init(int \*argc, char \*\*argv, int flags) {

   // 初始化内存分配pool。

   init\_alloc\_root(&plugin\_mem\_root, 4096, 4096);

   init\_alloc\_root(&tmp_root, 4096, 4096);

   // hash结构初始化

   ...

   // 初始化运行时plugin数组，plugin\_dl\_array用来保存动态加载plugin，plugin_array保存静态链接plugin。而且最多各自能有16个plugin。

   my\_init\_dynamic\_array(&plugin\_dl\_array, sizeof(struct st\_plugin_dl *),16,16);

   my\_init\_dynamic\_array(&plugin\_array, sizeof(struct st\_plugin\_int *),16,16);

   // 初始化静态链接plugin

   for (builtins= mysqld_builtins; *builtins; builtins++) {

   // 每一个plugin还可以有多个子plugin，参见见面的plugin申明。

   for (plugin= *builtins; plugin->info; plugin++) {

   register\_builtin(plugin, &tmp, &plugin\_ptr)； // 将plugin放到plugin\_array和plugin\_hash中。

   // 这个时候只初始化csv或者myisam plugin。

   plugin\_initialize(plugin\_ptr); // 初始化plugin,调用plugin的初始化函数，将plugin的状态变量加入到状态变量列表中，将系统变量的plugin成员指向当前的活动plugin。

   }

   }

   // 根据用户选项初始化动态加载plugin

   if (!(flags & PLUGIN\_INIT\_SKIP\_DYNAMIC\_LOADING))

   {

   if (opt\_plugin\_load)

   plugin\_load\_list(&tmp\_root, argc, argv, opt\_plugin_load); // 根据配置加载制定的plugin。包括找到dll,加载，寻找符号并设置plugin结构。

   if (!(flags & PLUGIN\_INIT\_SKIP\_PLUGIN\_TABLE))

   plugin\_load(&tmp\_root, argc, argv); // 加载系统plugin table中的plugin。

   }

   // 初始化剩下的plugin。

   for (i= 0; i < plugin_array.elements; i++) {

   plugin\_ptr= \*dynamic\_element(&plugin\_array, i, struct st\_plugin_int \*\*);

   if (plugin\_ptr->state == PLUGIN\_IS_UNINITIALIZED)

   {

   if (plugin_initialize(plugin_ptr))

   {

   plugin_ptr->state= PLUGIN\_IS_DYING;

   *(reap++)= plugin_ptr;

   }

   }

   }

   ...

}
```

这个函数执行结束以后，在plugin\_array,plugin\_dl\_array,plugin\_hash中保存了当前加载了的所有的plugin。到此plugin初始化结束。

在plugin\_initialize 函数里面，调用了每个plugin自己的init函数（参见前面的内容）。特别要提到的是对于各种不同类型的plugin,初始化函数的参数也不一样，这 是通过一个全局的plugin\_type\_initialize间接层来实现的。这个数组对于每种类型的plugin定义了一个函数，比如对于 storage plugin对应的是ha\_initialize\_handlerton，对于information scheme对应的是initialize\_schema_table，然后在这些函数中再调用plugin的初始化函数。暂时对于其他类型的 plugin没有定义这个中间层初始化函数，所以就直接调用了plugin的初始化函数。
