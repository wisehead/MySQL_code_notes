---
title: MySQL源码分析以及目录结构 - 鲁仕林 - 博客园
category: default
tags: 
  - www.cnblogs.com
created_at: 2020-05-16 22:45:38
original_url: https://www.cnblogs.com/lushilin/p/6086833.html
---


# MySQL源码分析以及目录结构 - 鲁仕林 - 博客园

**原文地址：**[MySQL源码分析以及目录结构](http://blog.sina.com.cn/s/blog_7045cb9e0100t5v9.html "MySQL源码分析以及目录结构")**作者：**[jacky民工](http://blog.sina.com.cn/u/1883622302 "jacky民工")

**主要模块及数据流**  
经过多年的发展，mysql的主要模块已经稳定，基本不会有大的修改。本文将对MySQL的整体架构及重要目录进行讲述。

1.  源码结构（MySQL-5.5.0-m2）
    *   BUILD: 内含在各个平台、各种编译器下进行编译的脚本。如compile-pentium-debug表示在pentium架构上进行编译的脚本。
    *   Client: 客户端工具，如mysql, mysqladmin之类。
    *   Cmd-line-utils: readline, libedit工具。
    *   Config: 给aclocal使用的配置文件。
    *   Dbug: 提供一些调试用的宏定义。
    *   Extra: 提供innochecksum，resolveip等额外的小工具。
    *   Include: 包含的头文件
    *   Libmysql: 库文件，生产libmysqlclient.so。
    *   Libmysql\_r: 线程安全的库文件，生成libmysqlclient\_r.so。
    *   Libservices: 5.5.0中新加的目录，实现了打印功能。
    *   Man: 手册页。
    *   Mysql-test: mysqld的测试工具一套。
    *   Mysys: 为跨平台计，MySQL自己实现了一套常用的数据结构和算法，如string, hash等。
    *   Netware: 在netware平台上进行编译时需要的工具和库。
    *   Plugin: mysql以插件形式实现的部分功能。
    *   Pstack: 异步栈追踪工具。
    *   Regex: 正则表达式工具。
    *   Scripts: 提供脚本工具，如mysql\_install\_db等
    *   Sql: mysql主要代码，将会生成mysqld文件。
    *   Sql-bench: 一些评测代码。
    *   Sql-common: 存放部分服务器端和客户端都会用到的代码。
    *   Storage: 存储引擎所在目录，如myisam, innodb, ndb等。
    *   Strings: string库。
    *   Support-files: my.cnf示例配置文件。
    *   Tests: 测试文件所在目录。
    *   Unittest: 单元测试。
    *   Vio: virtual io系统，是对network io的封装。
    *   Win: 给windows平台提供的编译环境。
    *   Zip: zip库工具
2.  主要数据结构
    *   THD 线程描述符(sql/sql_class.h)
    *   包含处理用户请求时需要的相关数据，每个连接会有一个线程来处理，在一些高层函数中，此数据结构常被当作第一个参数传递。  
        `NET net; // 客户连接描述符  
        Protocol *protocol; // 当前的协议  
        Protocol_text protocol_text; // 普通协议  
        Protocol_binary protocol_binary; // 二进制协议  
        HASH user_vars; //用户变量的hash值  
        String packet; // 网络IO时所用的缓存  
        String convert_buffer; // 字符集转换所用的缓存  
        struct sockaddr_in remote; //客户端socket地址`
        
        THR\_LOCK\_INFO lock_info; // 当前线程的锁信息  
        THR\_LOCK\_OWNER main\_lock\_id; // 在旧版的查询中使用  
        THR\_LOCK\_OWNER *lock\_id; //若非main\_lock\_id, 指向游标的lock\_id  
        pthread\_mutex\_t LOCK\_thd\_data; //thd的mutex锁，保护THD数据（thd->query, thd->query_length）不会被其余线程访问到。
        
        Statement\_map stmt\_map; //prepared statements和stored routines 会被重复利用  
        int insert(THD \*thd, Statement \*statement); // statement的hash容器  
        class Statement::  
        LEX_STRING name;  
        LEX *lex; //语法树描述符  
        bool set\_db(const char *new\_db, size\_t new\_db_len)  
        void set\_query(char *query\_arg, uint32 query\_length\_arg);  
        {  
        pthread\_mutex\_lock(&LOCK\_thd\_data);  
        set\_query\_inner(query\_arg, query\_length_arg);  
        pthread\_mutex\_unlock(&LOCK\_thd\_data);  
        }
        
    *   NET 网络连接描述符（sql/mysql_com.h）
    *   网络连接描述符，对内部数据包进行了封装，是client和server之间的通信协议。  
        `  
        Vio *vio; //底层的网络I/O socket描述符  
        unsigned char *buff,*buff_end,*write_pos,*read_pos; //缓存相关  
        unsigned long remain_in_buf,length, buf_length, where_b;  
        unsigned long max_packet,max_packet_size; //当前值;最大值  
        unsigned int pkt_nr,compress_pkt_nr; //当前（未）压缩包的顺序值  
        my_bool compress; //是否压缩  
        unsigned int write_timeout, read_timeout, retry_count; //最大等待时间  
        unsigned int *return_status; //thd中的服务器状态  
        unsigned char reading_or_writing;  
          
        unsigned int last_errno; //返回给客户端的错误号  
        unsigned char error;  
        `
        
    *   TABLE 数据库表描述符（sql/table.h）
    *   数据库表描述符，分成TABLE和TABLE_SHARE两部分。  
        `handler *file; //指向这张表在storage engine中的handler的指针  
        THD *in_use;  
        Field **field;  
        uchar *record[2];  
        uchar *write_row_record;  
        uchar *insert_values;  
          
        key_map covering_keys;  
        key_map quick_keys, merge_keys;  
        key_map keys_in_use_for_query;  
          
        key_map keys_in_use_for_group_by;  
          
        key_map keys_in_use_for_order_by;  
        KEY *key_info;`
        
        HASH name_hash; //数据域名字的hash值  
        MEM\_ROOT mem\_root; //内存块  
        LEX_STRING db;  
        LEX\_STRING table\_name;  
        LEX\_STRING table\_cache_key;  
        enum db\_type db\_type //当前表的storage engine类型  
        enum row\_type row\_type //当前记录是定长还是变长  
        uint primary_key;  
        uint next\_number\_index; //自动增长key的值  
        bool is_view ;  
        bool crashed;
        
    *   FIELD 字段描述符（sql/field.h）
    *   域描述符，是各种字段的抽象基类。  
        `uchar *ptr; // 记录中数据域的位置  
        uchar *null_ptr; // 记录 null_bit 位置的byte  
        TABLE *table; // 指向表的指针  
        TABLE *orig_table; // 指向原表的指针  
        const char **table_name, *field_name;  
        LEX_STRING comment;  
          
        key_map key_start, part_of_key, part_of_key_not_clustered;  
        key_map part_of_sortkey;  
          
        enum utype { NONE,DATE,SHIELD,NOEMPTY,CASEUP,PNR,BGNR,PGNR,YES,NO,REL,  
        CHECK,EMPTY,UNKNOWN_FIELD,CASEDN,NEXT_NUMBER,INTERVAL_FIELD,  
        BIT_FIELD, TIMESTAMP_OLD_FIELD, CAPITALIZE, BLOB_FIELD,  
        TIMESTAMP_DN_FIELD, TIMESTAMP_UN_FIELD, TIMESTAMP_DNUN_FIELD};  
        …..  
        virtual int store(const char *to, uint length,CHARSET_INFO *cs)=0;  
        inline String *val_str(String *str) { return val_str(str, str); }`
        
    *   Utility API Calls 各种API
    *   各种核心的工具，例如内存分配，字符串操作或文件管理。标准C库中的函数只使用了很少一部分，C++中的函数基本没用。  
        `void *my_malloc(size_t size, myf my_flags) //对malloc的封装  
        size_t my_write(File Filedes, const uchar *Buffer, size_t Count, myf MyFlags) //对write的封装`
        
    *   Preprocessor Macros 处理器宏
    *   Mysql中使用了大量的C预编译，随编译参数的不同最终代码也不同。  
        `#define max(a, b) ((a) > (b) ? (a) : (b)) //得出两数中的大者`
        
        do   
        {   
        char compile\_time\_assert\[(X) ? 1 : -1\]   
        \_\_attribute\_\_ ((unused));   
        } while(0)  
        使用gcc的attribute属性指导编译器行为  
        • Global variables 全局变量  
        • configuration settings  
        • server status information  
        • various data structures shared among threads  
        主要包括一些全局的设置，服务器信息和部分线程间共享的数据结构。  
        `struct system_status_var global_status_var; //全局的状态信息  
        struct system_variables global_system_variables; //全局系统变量`
        
3.  主要调用流程
    1.  MySQL启动
    2.  主要代码在sql/mysqld.cc中，精简后的代码如下：  
        `int main(int argc, char **argv) //标准入口函数  
        MY_INIT(argv[0]); //调用mysys/My_init.c->my_init()，初始化mysql内部的系统库  
        logger.init_base(); //初始化日志功能  
        init_common_variables(MYSQL_CONFIG_NAME,argc, argv, load_default_groups) //调用load_defaults(conf_file_name, groups, &argc, &argv)，读取配置信息  
        user_info= check_user(mysqld_user);//检测启动时的用户选项  
        set_user(mysqld_user, user_info);//设置以该用户运行  
        init_server_components();//初始化内部的一些组件，如table_cache, query_cache等。  
        network_init();//初始化网络模块，创建socket监听  
        start_signal_handler();// 创建pid文件  
        mysql_rm_tmp_tables() || acl_init(opt_noacl)//删除tmp_table并初始化数据库级别的权限。  
        init_status_vars(); // 初始化mysql中的status变量  
        start_handle_manager();//创建manager线程  
        handle_connections_sockets();//主要处理函数，处理新的连接并创建新的线程处理之`
        
    3.  监听接收链接
    4.  主要代码在sql/mysqld.cc中，精简后的代码如下：  
        `THD *thd;  
        FD_SET(ip_sock,&clientFDs); //客户端socket  
        while (!abort_loop)  
        readFDs=clientFDs;  
        if (select((int) max_used_connection,&readFDs,0,0,0) error && net->vio != 0 &&  
        !(thd->killed == THD::KILL_CONNECTION))  
        {  
        if(do_command(thd)) //处理客户端发出的命令  
        break;  
        }  
        end_connection(thd);  
        }`
        
    5.  预处理连接
    6.  `thread_count++;//增加当前连接的线程  
        thread_scheduler.add_connection(thd);  
        for (;;) {  
        lex_start(thd);  
        login_connection(thd); // 认证  
        prepare_new_connection_state(thd); //初始化thd描述符  
        while(!net->error && net->vio != 0 &&  
        !(thd->killed == THD::KILL_CONNECTION))  
        {  
        if(do_command(thd)) //处理客户端发出的命令  
        break;  
        }  
        end_connection(thd);  
        }`
        
    7.  处理
    8.  do\_command在sql/sql\_parse.cc中：读取客户端传递的命令并分发。  
        `NET *net= &thd->net;  
        packet_length= my_net_read(net);  
        packet= (char*) net->read_pos;  
        command= (enum enum_server_command) (uchar) packet[0]; //从net结构中获取命令  
        dispatch_command(command, thd, packet+1, (uint) (packet_length-1));//分发命令  
        在dispatch_command函数中，根据命令的类型进行分发。  
        thd->command=command;  
        switch( command ) {  
        case COM_INIT_DB: ...;  
        case COM_TABLE_DUMP: ...;  
        case COM_CHANGE_USER: ...;  
        ….  
        case COM_QUERY: //如果是查询语句  
        {  
        alloc_query(thd, packet, packet_length)//thd->set_query(query, packet_length);  
        mysql_parse(thd, thd->query(), thd->query_length(), &end_of_stmt);  
        // 解析查询语句  
        ….  
        }`  
        在mysql_parse函数中，  
        `lex_start(thd);  
        if (query_cache_send_result_to_client(thd, (char*) inBuf, length) sql_command`  
        在mysql\_execute\_command中，根据命令类型，转到相应的执行函数。  
        `switch (lex->sql_command) {  
        LEX *lex= thd->lex;  
        TABLE_LIST *all_tables;  
        case SQLCOM_SELECT:  
        check_table_access(thd, lex->exchange ? SELECT_ACL | FILE_ACL : SELECT_ACL, all_tables, UINT_MAX, FALSE); //检查用户权限  
        execute_sqlcom_select(thd, all_tables); //执行select命令  
        break;`
        
        case SQLCOM_INSERT:  
        { res= insert\_precheck(thd, all\_tables) //rights  
        mysql\_insert(thd, all\_tables, lex->field\_list, lex->many\_values,  
        lex->update\_list, lex->value\_list,  
        lex->duplicates, lex->ignore);  
        break;  
        在execute\_sqlcom\_select函数中，  
        `res= open_and_lock_tables(thd, all_tables)//directly and indirectly  
        res= handle_select(thd, lex, result, 0);`  
        handle\_select在sql\_select.cc中，调用mysql\_select ，在mysql\_select中，  
        `join->prepare();//Prepare of whole select (including sub queries in future).  
        join->optimize();//global select optimisation.  
        join->exec();//`  
        在mysql_insert函数中，  
        `open_and_lock_tables(thd, table_list)  
        mysql_prepare_insert(); //prepare item in INSERT statment  
        while ((values= its++))  
        write_record(thd, table ,&info);//写入新的数据`  
        在write_record函数中，  
        `table->file->ha_write_row(table->record[0])  
        ha_write_row在Handler.cc中，只是一个接口  
        write_row(buf); //调用表存储所用的引擎`
        
4.  当客户端链接上mysql服务端时，系统为其分配一个链接描述符thd，用以描述客户端的所有信息，将作为参数在各个模块之间传递。一个典型的客户端查询在MySQL的主要模块之间的调用关系如下图所示：  
      
    
    当mysql启动完毕后，调用handle\_connection\_sockets等待客户端连接。当客户端连接上服务器时，服务处理函数将接受连 接，会为其创建链接线程，并进行认证。如认证通过，每个连接线程将会被分配到一个线程描述符thd，可能是新创建的，也可能是从 cached\_thread线程池中复用的。该描述符包含了客户端输入的所有信息，如查询语句等。服务器端会层层解析命令，根据命令类型的不同，转到相应 的sql执行函数，进而给传递给下层的存储引擎模块，处理磁盘上的数据库文件，最后将结果返回。执行完毕后thd将被加入cached\_thread中。

---------------------------------------------------


原网址: [访问](https://www.cnblogs.com/lushilin/p/6086833.html)

创建于: 2020-05-16 22:45:38

目录: default

标签: `www.cnblogs.com`

