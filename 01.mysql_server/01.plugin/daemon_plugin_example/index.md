---
title: MySQL:如何编写daemon plugin （zhuan） - wtx - 博客园
category: default
tags: 
  - www.cnblogs.com
created_at: 2020-05-17 16:05:43
original_url: https://www.cnblogs.com/hitwtx/archive/2012/01/14/2322435.html
---

# [MySQL:如何编写daemon plugin （zhuan）](https://www.cnblogs.com/hitwtx/archive/2012/01/14/2322435.html)

mysql 

1.什么是DaemonPlugin

顾名思义，daemon plugin就是一种用来在后台运行的插件，在插件中，我们可以创建一些后台线程来做些有趣的事情。大名鼎鼎的handlesocket就是一个daemon plugin。而在[mysql](http://www.2cto.com/database/mysql/)5.6中，也是通过daemon plugin来实现了memcached功能。

2.为什么使用DaemonPlugin

就像handlersocket，大胆的想象力能够创造无限的可能。MySQL Plugin的诱人之处在于其与Mysqld处于同一进程空间中，可以利用任何mysql内核的函数。Handlersocket在实现时，构造出相关参数并直接调用存储引擎的接口，从而穿越了语法解析和优化部分，对于逻辑简单的查询而言，可以极大的提高效率。

另外所有的plugin都提供了showstatus和show variables 命令的接口，因此我们可以利用plugin来显示一些我们想要的信息，例如mysql内部的全局变量值。

总的来说，daemon plugin可以做到以下几点：

1) 创建后台线程，扩展mysql功能

2）扩展status和variables信息

Deamon plugin在mysqld启动时进行初始化，执行完init函数， 因此并不适用于与服务器进行通信的情形，mysql也没有提供任何相关的API

3.如何编写daemonplugin

这里涉及到的一些结构体，对其他类型的plugin而言也是通用的

1)st\_mysql\_plugin

无论声明哪种plugin，至少要包含该结构体

<table border="1" cellspacing="0" cellpadding="0"><tbody><tr><td valign="top"><p>字段</p></td><td valign="top"><p>类型</p></td><td valign="top"><p>描述</p></td></tr><tr><td valign="top"><p>type</p></td><td valign="top"><p>int</p></td><td valign="top"><p>用于描述plugin的类型，随着版本更新，越来越多，在5.5中包含8种类型：</p><p>MYSQL_UDF_PLUGIN</p><p>MYSQL_STORAGE_ENGINE_PLUGIN</p><p>MYSQL_FTPARSER_PLUGIN</p><p>MYSQL_DAEMON_PLUGIN</p><p>MYSQL_INFORMATION_SCHEMA_PLUGIN</p><p>MYSQL_AUDIT_PLUGIN</p><p>MYSQL_REPLICATION_PLUGIN</p><p>MYSQL_AUTHENTICATION_PLUGIN</p></td></tr><tr><td valign="top"><p>info</p></td><td valign="top"><p>void*</p></td><td valign="top"><p>用于指向特定的plugin描述符结构体，在daemon plugin中结构体为st_mysql_daemon，一般第一个字段都是插件接口的版本号</p></td></tr><tr><td valign="top"><p>name</p></td><td valign="top"><p>const char*</p></td><td valign="top"><p>plugin的名字，需要和安装时的名字一致</p></td></tr><tr><td valign="top"><p>author</p></td><td valign="top"><p>const char*</p></td><td valign="top"><p>plugin的作者信息，会在i_s.plugins表中显示</p></td></tr><tr><td valign="top"><p>descry</p></td><td valign="top"><p>const char*</p></td><td valign="top"><p>描述插件</p></td></tr><tr><td valign="top"><p>license</p></td><td valign="top"><p>ubt</p></td><td valign="top"><p>插件许可证：PLUGIN_LICENSE_PROPRIETARY</p><p>PLUGIN_LICENSE_GPL</p><p>PLUGIN_LICENSE_BSD</p></td></tr><tr><td valign="top"><p>init</p></td><td valign="top"><p>int (*init)(void *)</p></td><td valign="top"><p>当插件被加载时或者mysqld重启时会执行该函数，一般我们会在这里创建好后台线程</p></td></tr><tr><td valign="top"><p>deinit</p></td><td valign="top"><p>int (*deinit)(void *);</p></td><td valign="top"><p>当插件被卸载时做的工作，例如取消线程，清理内存等</p></td></tr><tr><td valign="top"><p>version</p></td><td valign="top"><p>unsigned int</p></td><td valign="top"><p>plugin的版本信息</p></td></tr><tr><td valign="top"><p>status_vars</p></td><td valign="top"><p><a name="OLE_LINK2" data-mx-warn="Empty URL"></a><a name="OLE_LINK1" data-mx-warn="Empty URL"></a>st_mysql_show_var*</p></td><td valign="top"><p>描述在执行show status时显示的信息</p></td></tr><tr><td valign="top"><p>system_vars</p></td><td valign="top"><p><a name="OLE_LINK4" data-mx-warn="Empty URL"></a><a name="OLE_LINK3" data-mx-warn="Empty URL"></a>st_mysql_sys_var&nbsp;**</p></td><td valign="top"><p>描述在执行show variables显示的信息</p></td></tr><tr><td valign="top"><p>__reserved1</p></td><td valign="top"><p>void*</p></td><td valign="top"><p>注释说为检查依赖而保留，不太明白，直接设为NULL即可</p></td></tr><tr><td valign="top"><p>flags</p></td><td valign="top"><p>unsigned long</p></td><td valign="top"><p>5.5之后增加的字段，plugin的flag：0、</p><p>PLUGIN_OPT_NO_INSTALL(不可动态加载)、PLUGIN_OPT_NO_UNINSTALL（不可动态加载）</p></td></tr></tbody></table>

在plugin.h里提供了宏，我们可以通过宏来声明插件：

mysql\_declare\_plugin(my_plugin)

{},

{},

……

mysql\_declare\_plugin_end;

在两个宏之间，我们可以声明多个插件，也就是说在一个文件里，我们可以定义多个Plugin。

上面提到三个结构体，需要在plugin里单独进行定义：

a. st\_mysql\_daemon

该结构体只包含一个字段，用于声明daemon plugin的版本信息

<table border="1" cellspacing="0" cellpadding="0"><tbody><tr><td valign="top"><p>字段</p></td><td valign="top"><p>类型</p></td><td valign="top"><p>描述</p></td></tr><tr><td valign="top"><p>interface_version</p></td><td valign="top"><p>int</p></td><td valign="top"><p>一般值为</p><p>MYSQL_DAEMON_INTERFACE_VERSION</p></td></tr></tbody></table>

也许有同学注意到了，这上面提到了两个version，即st\_mysql\_plugin里的version和st\_mysql\_daemon里的version，这两者是不相同的。

st\_mysql\_plugin.version记录的是该plugin的版本号，使用16进制表示，低8位存储副版本号，其他存储主版本号。

而st\_mysql\_daemon里存储的是daemonplugin接口的版本号，针对不同的mysql版本，其接口可能会发生变化。

b. st\_mysql\_show_var

结构体如下：

<table border="1" cellspacing="0" cellpadding="0"><tbody><tr><td valign="top"><p>字段</p></td><td valign="top"><p>类型</p></td><td valign="top"><p>描述</p></td></tr><tr><td valign="top"><p>name</p></td><td valign="top"><p>const char*</p></td><td valign="top"><p>字段名</p></td></tr><tr><td valign="top"><p>value</p></td><td valign="top"><p>char*</p></td><td valign="top"><p>字段值，我们可以将指针绑定到一个全局变量上</p></td></tr><tr><td valign="top"><p>type</p></td><td valign="top"><p>enum enum_mysql_show_type</p></td><td valign="top"><p>数据类型，包括(括号里对应value的指针类型)：</p><p>SHOW_BOOL （bool *）</p><p>SHOW_INT &nbsp;&nbsp;(unsigned int *)</p><p>SHOW_LONG (long *)</p><p>SHOW_LONGLONG (long long*)</p><p>SHOW_DOUBLE (double *)</p><p>SHOW_CHAR &nbsp;&nbsp;(char *)</p><p>SHOW_CHAR_PTR (char **)</p><p>SHOW_ARRAY(st_mysql_show_var * )</p><p>SHOW_FUNC(</p><p>int (*)(MYSQL_THD, struct&nbsp;<a name="OLE_LINK6" data-mx-warn="Empty URL"></a><a name="OLE_LINK5" data-mx-warn="Empty URL"></a>st_mysql_show_var*, char *) )</p></td></tr></tbody></table>

该结构体用于定义show status时显示的值，可以看出在type字段最后两个相对其他比较特殊。

当type类型为SHOW\_ARRAY时，表明name字段并不是一个值，而是指向一个st\_mysql\_show\_var类型的数组，数组以{0，0，0}结束，当前元素的name会成为引用数组元素name的前缀。

当type类型为SHOW\_FUNC时，value值为一个函数指针，参数包括当前线程的THD，st\_mysql\_show\_var* 以及一个大小为1024字节的内存区域头指针；函数的目的是为了填充第二个字段的值，而buf作为存储构建结构体的内存空间；这样可以允许我们先做一些计算，然后显示计算的结果。

c. st\_mysql\_sys_var

该结构体内包含一个宏MYSQL\_PLUGIN\_VAR_HEADER，包含了变量结构体的公共部分。

在这里，MySQL巧妙的使用了C的宏定义，例如，当我们定义一个variable：

struct st\_mysql\_sys\_var* my\_sysvars\[\]= {

MYSQL\_SYSVAR(my\_var),

NULL}

展开MYSQL_SYSVAR看看：

#define MYSQL\_SYSVAR\_NAME(name)mysql\_sysvar\_ ## name

#define MYSQL_SYSVAR(name) \

 ((struct st\_mysql\_sys\_var *)&(MYSQL\_SYSVAR_NAME(name)))

那么MYSQL\_SYSVAR(my\_var)被转换为：

((struct st\_mysql\_sys\_var *)mysql\_sysvar\_my\_var

因此，在这之前，我们首先要先创建好结构体。针对不同的数据类型，提供了许多宏来创建，分为两种：一种以MYSQL\_SYSVAR开头的全局变量（可以set global），另外一种是MYSQL\_THDVAR开头的session变量

<table style="width: 593px;" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td valign="top"><p>MYSQL_SYSVAR_BOOL(name, varname, opt, comment, check, update, def)</p></td><td valign="top"><p>char</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_STR(name, varname, opt, comment, check, update, def)</p></td><td valign="top"><p>char*</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_INT(name, varname, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>int</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_UINT(name, varname, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>unsigned int</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_LONG(name, varname, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>long</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_ULONG(name, varname, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>unsigned long</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_LONGLONG(name, varname, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>long long</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_ULONGLONG(name, varname, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>unsigned long long</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_ENUM(name, varname, opt, comment, check, update, def, typelib)</p></td><td valign="top"><p>unsigned long</p></td></tr><tr><td valign="top"><p>MYSQL_SYSVAR_SET(name, varname, opt, comment, check, update, def, typelib)</p></td><td valign="top"><p>unsigned long long</p></td></tr><tr><td colspan="2" valign="top" width="593"><p>以下是session变量定义宏</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_BOOL(name, opt, comment, check, update, def)</p></td><td valign="top"><p>char</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_STR(name, opt, comment, check, update, def)</p></td><td valign="top"><p>char*</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_INT(name, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>int</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_UINT(name, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>unsigned int</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_LONG(name, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>long</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_ULONG(name, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>unsigned long</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_LONGLONG(name, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>long long</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_ULONGLONG(name, opt, comment, check, update, def, min, max, blk)</p></td><td valign="top"><p>unsigned long long</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_ENUM(name, opt, comment, check, update, def, typelib)</p></td><td valign="top"><p>unsigned long</p></td></tr><tr><td valign="top"><p>MYSQL_THDVAR_SET(name, opt, comment, check, update, def, typelib)</p></td><td valign="top"><p>unsigned long long</p></td></tr></tbody></table>

宏中参数描述如下：

<table border="1" cellspacing="0" cellpadding="0"><tbody><tr><td valign="top"><p>参数名</p></td><td valign="top"><p>描述</p></td></tr><tr><td valign="top"><p>name</p></td><td valign="top"><p>变量名，通过show variables显示的变量名，</p></td></tr><tr><td valign="top"><p>varname</p></td><td valign="top"><p>C/C++变量，用来给name赋值</p></td></tr><tr><td valign="top"><p>opt</p></td><td valign="top"><p>变量选项：</p><p>PLUGIN_VAR_READONLY （变量只读）</p><p>PLUGIN_VAR_NOSYSVAR （不是系统变量，只能在启动时命令行加上）</p><p>PLUGIN_VAR_NOCMDOPT （与上述相反）</p><p>PLUGIN_VAR_NOCMDARG （命令行，必须没有参数）</p><p>PLUGIN_VAR_RQCMDARG （命令行，不需有参数）</p><p>PLUGIN_VAR_OPCMDARG （命令行，参数可选）</p><p>PLUGIN_VAR_MEMALLOC （如果被设置，会分配内存存储字符串的值，否则只能通过命令行来分配）</p></td></tr><tr><td valign="top"><p>comment</p></td><td valign="top"><p>变量的描述信息</p></td></tr><tr><td valign="top"><p>check</p></td><td valign="top"><p>函数指针，用来检查参数是否有效，如果无效，则拒绝修改，函数原型为：</p><p>int check(MYSQL_THD thd, struct st_mysql_sys_var *var, void *save, struct st_mysql_value *value);</p><p>其中thd为当前线程，var是我们定义的系统变量，save指针用来存储数据，value是传递给函数的值，我们可以从value中获取值，并将其保存到save中。</p></td></tr><tr><td valign="top"><p>update</p></td><td valign="top"><p>函数指针，当发生更新时，可以调用该函数做一些额外处理，函数原型为：</p><p>void update(MYSQL_THD thd, struct st_mysql_sys_var *var, void *var_ptr, const void *save);</p></td></tr><tr><td valign="top"><p>def</p></td><td valign="top"><p>变量的默认值</p></td></tr><tr><td valign="top"><p>min</p></td><td valign="top"><p>最小值 （min及以下两个需要为数值类型）</p></td></tr><tr><td valign="top"><p>max</p></td><td valign="top"><p>最大值</p></td></tr><tr><td valign="top"><p>blk</p></td><td valign="top"><p>块大小，变量值需要是blk的整数倍</p></td></tr><tr><td valign="top"><p>typelib</p></td><td valign="top"><p>当变量类型为ENUM和SET类型时，使用该结构体定义：st_typelib</p></td></tr></tbody></table>

在check函数里，我们从var中提取出新的值，并存储到save指针中。在update函数中，我们可以从save指针提取出新值，st\_mysql\_value正是用于提取新值的结构体，成员为函数指针，如下：

<table border="1" cellspacing="0" cellpadding="0"><tbody><tr><td valign="top"><p>函数指针</p></td><td valign="top"><p>描述</p></td></tr><tr><td valign="top"><p>int (*value_type)(struct st_mysql_value *)</p></td><td valign="top"><p>用于获取值的类型：</p><p>MYSQL_VALUE_TYPE_STRING 0</p><p>MYSQL_VALUE_TYPE_REAL&nbsp;&nbsp; 1</p><p>MYSQL_VALUE_TYPE_INT&nbsp;&nbsp;&nbsp; 2</p></td></tr><tr><td valign="top"><p>const char *(*val_str)(struct st_mysql_value *, char *buffer, int *length);</p></td><td valign="top"><p>获取字符串</p></td></tr><tr><td valign="top"><p>int (*val_int)(struct st_mysql_value *, long long *intbuf);</p></td><td valign="top"><p>获取整数</p></td></tr></tbody></table>

例如:

Int a ;

Var->val_int(var, &a);

一些系统变量允许为SET或者ENUM类型，这时候，需要通过额外的结构体st_typelib来定义：

<table border="1" cellspacing="0" cellpadding="0"><tbody><tr><td valign="top"><p>字段</p></td><td valign="top"><p>类型</p></td><td valign="top"><p>描述</p></td></tr><tr><td valign="top"><p>count</p></td><td valign="top"><p>unsigned int</p></td><td valign="top"><p>type_names里的元素个数</p></td></tr><tr><td valign="top"><p>name</p></td><td valign="top"><p>const char*</p></td><td valign="top"><p>plugin无需设置</p></td></tr><tr><td valign="top"><p>type_names</p></td><td valign="top"><p>const char**</p></td><td valign="top"><p>存储集合内的元素值</p></td></tr><tr><td valign="top"><p>type_lengths</p></td><td valign="top"><p>unsigned int*</p></td><td valign="top"><p>plugin无需设置</p></td></tr></tbody></table>

举个简单的例子，比如我们想定义一个INT变量,该变量为只读类型，即不允许通过set命令修改，最大为1000000，最小为0 ，默认值为 256：

Static int xx

Static MYSQL\_SYSVAR\_INT(xx\_var, xx , PLUGIN\_VAR_READONLY , “a read onlyint var”, NULL, NULL,256, 0, 1000000, 10)

例如，如果plugin的名字为name,则变量的全名为name\_xx\_var。我们可以将系统变量通过命令行来赋值，也可以写在配置文件中，变量名为name-xx-var，赋值必须能被10整除，否则将被mysql拒绝。

定义一个枚举类型，session变量

static const char *mode_names\[\] = {

"NORMAL", "TURBO","SUPER", "HYPER", "MEGA"

};

static TYPELIB modes = { 5, NULL,mode_names, NULL };

static MYSQL\_THDVAR\_ENUM(mode,PLUGIN\_VAR\_NOCMDOPT,

"one of NORMAL, TURBO, SUPER, HYPER,MEGA",

NULL, NULL, 0, &modes);

该变量属于枚举类型，每个session拥有自己的值，并且可在运行时修改；注意，当为session变量时，我们需要通过THDVAR(thd,mode)这样一个宏来获取相应的变量值

另外，对于Plugin中的系统变量无需加互斥锁，MySQL会自动给我们加上。

实例：启动一个后台线程，每隔5秒监控当前进程的状态（记录到log中），使用系统变量来控制是否记录log，并在show status显示记录的次数

#include <string.h> 

#include <plugin.h> 

#include<mysql_version.h> 

#include <my_global.h> 

#include <my_sys.h> 

#include<sys/resource.h> 

#include <sys/time.h> 

#define MONITORING_BUFFER1024 

/*以下三个变量在sql/mysqld.cc中声明，因此需要extern*/ 

extern ulong thread_id;  //当前最大线程id 

extern uint thread_count;  //当前线程数 

extern ulong max_connections;//最大允许连接数 

static pthread\_tmonitoring\_thread; //线程id 

static int monitoring_file;         //日志文件fd 

static my\_bool monitor\_state= 1;   //为1表示记录日志，为0则否 

static ulong monitor_num     = 0;   //后台线程循环次数 

static struct rusage usage;         

/*创建系统变量，可以通过配置文件或set global来修改*/ 

MYSQL\_SYSVAR\_BOOL(monitors\_state,monitor\_state, 

              PLUGIN\_VAR\_OPCMDARG, 

              "disable monitor  if 0,default TRUE", 

              NULL, NULL, TRUE); 

struct st\_mysql\_sys\_var*vars\_system_var\[\] = { 

        MYSQL\_SYSVAR(monitors\_state), 

            NULL 

}; 

/*创建status变量，可通过showstatus查看*/ 

static structst\_mysql\_show\_var sys\_status_var\[\] = 

{ 

    {"monitor\_num", (char *)&monitor\_num, SHOW_LONG}, 

    {0, 0, 0} 

}; 

/*线程函数，后台线程启动后，会持续执行该函数*/ 

pthread\_handler\_tmonitoring(void *p) 

{ 

    char buffer\[MONITORING_BUFFER\]; 

    char time_str\[20\]; 

while(1) { 

/*每隔5秒记录一次，我们也可以把5修改为一个可配置的系统变量*/ 

        sleep(5); 

        if (!monitor_state) 

            continue; 

        monitor_num++; 

/*获取当前时间，mysql自有函数*/ 

        get\_date(time\_str, GETDATE\_DATE\_TIME,0); 

        snprintf(buffer, MONITORING_BUFFER,"%s: %u of %lu clients connected, " 

                "%lu connections made\\n", 

                time\_str, thread\_count, 

                max\_connections, thread\_id); 

/*使用getrusage函数来获得当前进程的运行状态，具体man getrusage*/ 

        if (getrusage(RUSAGE_SELF, &usage)== 0){ 

            snprintf(buffer+strlen(buffer) , 

MONITORING_BUFFER, "user time:%d,system time:%d," 

                                                "maxrss:%d,ixrss:%d,idrss:%d," 

                                                "isrss:%d, minflt:%d, majflt:%d," 

                                                 "nswap:%d,inblock:%d,oublock:%d," 

                                                "msgsnd:%d, msgrcv:%d,nsignals:%d," 

                                                "nvcsw:%d, nivcsw:%d\\n", 

                       usage.ru_utime, 

                       usage.ru_stime, 

                       usage.ru_maxrss, 

                       usage.ru_ixrss, 

                       usage.ru_idrss, 

                       usage.ru_isrss, 

                       usage.ru_minflt, 

                       usage.ru_majflt, 

                       usage.ru_nswap, 

                       usage.ru_inblock, 

                       usage.ru_oublock, 

                       usage.ru_msgsnd, 

                       usage.ru_msgrcv, 

                       usage.ru_nsignals, 

                       usage.ru_nvcsw, 

                       usage.ru_nivcsw); 

            /*写入monitoring_file文件*/ 

            write(monitoring_file, buffer,strlen(buffer)); 

        } 

    } 

} 

/*系统启动或加载插件时时调用该函数，用于创建后台线程*/ 

static int monitoring\_plugin\_init(void*p) 

{ 

    pthread\_attr\_t attr; 

    char monitoring\_filename\[FN\_REFLEN\]; 

    char buffer\[MONITORING_BUFFER\]; 

    char time_str\[20\]; 

     monitor_num = 0; 

    /*format the filename

     *The fn_format() function is designed tobuild a filename and path compatible

     with the current operating system given aset of parameters. More details on its

     functionality can be found inmysys/mf_format.c.

     \* */ 

    fn\_format(monitoring\_filename,"monitor", "", ".log", 

            MY\_REPLACE\_EXT |MY\_UNPACK\_FILENAME); 

    unlink(monitoring_filename); 

    monitoring\_file = open(monitoring\_filename, 

            O\_CREAT | O\_RDWR, 0644); 

    if (monitoring_file < 0) 

    { 

        fprintf(stderr, "Plugin'monitoring': " 

                "Could not create file '%s'\\n", 

                monitoring_filename); 

        return 1; 

    } 

    get\_date(time\_str, GETDATE\_DATE\_TIME, 0); 

    sprintf(buffer, "Monitoring started at%s\\n", time_str); 

    write(monitoring_file, buffer,strlen(buffer)); 

    pthread\_attr\_init(&attr); 

    pthread\_attr\_setdetachstate(&attr,PTHREAD\_CREATE\_JOINABLE); 

    if (pthread\_create(&monitoring\_thread,&attr, 

                monitoring, NULL) != 0){ 

        fprintf(stderr, "Plugin'monitoring': " 

                "Could not create monitoringthread!\\n"); 

        return 1; 

    } 

    return 0; 

} 

/*卸载插件时调用*/ 

static intmonitoring\_plugin\_deinit(void *p) 

{ 

    char buffer\[MONITORING_BUFFER\]; 

char time_str\[20\]; 

/*通知后台线程结束*/ 

    pthread\_cancel(monitoring\_thread); 

    pthread\_join(monitoring\_thread, NULL); 

    get\_date(time\_str, GETDATE\_DATE\_TIME, 0); 

    sprintf(buffer, "Monitoring stopped at%s\\n", time_str); 

    write(monitoring_file, buffer,strlen(buffer)); 

    close(monitoring_file); 

    return 0; 

} 

struct st\_mysql\_daemonmonitoring\_plugin = { MYSQL\_DAEMON\_INTERFACE\_VERSION }; 

/*声明插件*/ 

mysql\_declare\_plugin(monitoring) 

{ 

    MYSQL\_DAEMON\_PLUGIN, 

    &monitoring_plugin, 

    "monitoring", 

    "yinfeng", 

    "a daemon montor,log process usagestate", 

    PLUGIN\_LICENSE\_GPL, 

    monitoring\_plugin\_init, 

    monitoring\_plugin\_deinit, 

    0x0100, 

    sys\_status\_var, 

    vars\_system\_var, 

    NULL 

} 

mysql\_declare\_plugin_end; 

posted @ 2012-01-14 16:12  [wtx](https://www.cnblogs.com/hitwtx/)  阅读(1161)  评论(0)  [编辑](https://i.cnblogs.com/EditPosts.aspx?postid=2322435)  [收藏](javascript:)

---------------------------------------------------


原网址: [访问](https://www.cnblogs.com/hitwtx/archive/2012/01/14/2322435.html)

创建于: 2020-05-17 16:05:43

目录: default

标签: `www.cnblogs.com`

