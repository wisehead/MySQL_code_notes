
# MySQL -- 内存使用监控详解 - 蒋乐兴的技术随笔 - 博客园

**问题：**

　　1、我们怎么确定MySQL的各个部分分别使用了多少内存？

　　2、当有MySQL由于内存泄露引起OOM时、我们怎么提前发现？

**怎么监控MySQL内存使用：**

　　答案是通过performance\_schema来完成、具体的做法如下：

**第一步： 配置performance\_schema使它开启内存方面的监控**

　　在/etc/my.cnf中增加如下内容

[![复制代码](assets/1619063893-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
####  for performance_schema
performance_schema                                                      =on    #    on
performance_schema_consumer_events_stages_current                       =on    #    off
performance_schema_consumer_events_stages_history                       =on    #    off
performance_schema_consumer_events_stages_history_long                  =off   #    off
performance_schema_consumer_statements_digest                           =on    #    on
performance_schema_consumer_events_statements_current                   =on    #    on
performance_schema_consumer_events_statements_history                   =on    #    on
performance_schema_consumer_events_statements_history_long              =off   #    off
performance_schema_consumer_events_waits_current                        =on    #    off
performance_schema_consumer_events_waits_history                        =on    #    off
performance_schema_consumer_events_waits_history_long                   =off   #    off
performance_schema_consumer_global_instrumentation                      =on    #    on
performance_schema_consumer_thread_instrumentation                      =on    #    on
performance-schema-instrument                                           ='memory/%=COUNTED'
```

[![复制代码](assets/1619063893-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

**第二步：重启mysql数据库**

```plain
systemctl restart mysql
```

　　这里要重启MySQL的主要是因为，许多的内存是在启动MySQL的时候就分配好了的，如果我们在MySQL启动完成后再通过

　　performance\_schema.setup\_instrument表来配置内存相关的监控的话，就是漏掉一些内存没有监控到。

**第三步：通过performance\_schema查询内存的使用情况**

[![复制代码](assets/1619063893-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
mysql> SELECT SUBSTRING_INDEX(event_name,'/',2) AS code_area, sys.format_bytes(SUM(current_alloc)) AS current_alloc
    -> FROM sys.x$memory_global_by_current_bytes GROUP BY SUBSTRING_INDEX(event_name,'/',2) ORDER BY SUM(current_alloc) DESC;
+---------------------------+---------------+
| code_area                 | current_alloc |
+---------------------------+---------------+
| memory/innodb             | 1.47 GiB      |
| memory/performance_schema | 131.51 MiB    |
| memory/mysys              | 8.22 MiB      |
| memory/sql                | 3.19 MiB      |
| memory/memory             | 213.15 KiB    |
| memory/myisam             | 171.79 KiB    |
| memory/csv                | 512 bytes     |
| memory/blackhole          | 512 bytes     |
+---------------------------+---------------+
8 rows in set (0.00 sec)
```

[![复制代码](assets/1619063893-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

　　1、从上面的结果我们可以知道innodb、performance\_schema、mysys ... 它们共用了多少内存了、如果某一类组件的内存使用没有节制的增长上去、多半

　　它就是内存泄露了。 对于这种情况只能是升级MySQL到更高的版本了。

**目前performance-schema相关的配置模板已经增加到mysqltools当中**

　　[https://github.com/Neeky/mysqltools/blob/master/deploy/ansible/mysql/template/5.7/my.cnf](https://github.com/Neeky/mysqltools/blob/master/deploy/ansible/mysql/template/5.7/my.cnf)

\----------------------------------------------------------------------------

![](assets/1619063893-fa8889b1a9d25c24e740edbb03f47ff5.jpg)![](assets/1619063893-992aa4a64c2564658441cdbf28492a7d.jpg)

\----------------------------------------------------------------------------