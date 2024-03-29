
#3.handle_one_connection

```cpp
caller:
--pfs_spawn_thread

/*
  Thread handler for a connection

  SYNOPSIS
    handle_one_connection()
    arg   Connection object (THD)

  IMPLEMENTATION
    This function (normally) does the following:
    - Initialize thread
    - Initialize THD to be used with this thread
    - Authenticate user
    - Execute all queries sent on the connection
    - Take connection down
    - End thread  / Handle next connection using thread from thread cache
*/

handle_one_connection
--mysql_thread_set_psi_id
----get_thread
----set_thread_id
--do_handle_one_connection
----thd_prepare_connection
----while (thd_is_connection_alive(thd))
----do_command//in while
--end_connection(thd)
--close_connection(thd);
```

#4.create_thread_to_handle_connection

```cpp
caller:
mysqld_main
--init_common_variables
----get_options
------one_thread_per_connection_scheduler
--------create_thread_to_handle_connection

create_thread_to_handle_connection
--//if (blocked_pthread_count <=  wake_pthread)
--mysql_thread_create(key_thread_one_connection,
                                    &thd->real_id, &connection_attrib,
                                    handle_one_connection,
                                    (void*) thd)))
--add_global_thread                                    
```

#5.mysql_thread_create

```cpp
mysql_thread_create    
--inline_mysql_thread_create    
----spawn_thread
------spawn_thread_v1
--------pthread_create(thread, attr, pfs_spawn_thread, psi_arg);
----------pfs_spawn_thread
```

#6. handle_connections_sockets
主要代码在sql/mysqld.cc中(handle_connections_sockets)，精简后的代码如下：

```cpp

pthread_handler_t handle_connections_sockets(void *arg __attribute__((unused))) {
    FD_SET(unix_sock,&clientFDs); // unix_socket在network_init中被打开
    while (!abort_loop) { // abort_loop是全局变量，在某些情况下被置为1表示要退出。
        readFDs=clientFDs; // 需要监听的socket
        select((int) max_used_connection,&readFDs,0,0,0); // select异步(?科学家解释下是同步还是异步)监听，当接收到??以后返回。
        new_sock = accept(sock, my_reinterpret_cast(struct sockaddr *) (&cAddr),   &length); // 接受请求
        thd= new THD; // 创建mysqld任务线程描述符，它封装了一个客户端连接请求的所有信息
        vio_tmp=vio_new(new_sock, VIO_TYPE_SOCKET, VIO_LOCALHOST); // 网络操作抽象层
        my_net_init(&thd->net,vio_tmp)); // 初始化任务线程描述符的网络操作
        create_new_thread(thd); // 创建任务线程
    }
}
```

#6. create_new_thread

```cpp
caller:
--handle_connections_sockets

static void create_new_thread(THD *thd) {
    NET *net=&thd->net;
    if (connection_count >= max_connections + 1 || abort_loop) { // 看看当前连接数是不是超过了系统配置允许的最大值，如果是就断开连接。
        close_connection(thd, ER_CON_COUNT_ERROR, 1);
        delete thd;
    }
    ++connection_count;
    thread_scheduler.add_connection(thd); // 将新连接加入到thread_scheduler的连接队列中。
}

create_new_thread
--MYSQL_CALLBACK(thd->scheduler, add_connection, (thd));
--one_thread_per_connection_scheduler
--create_thread_to_handle_connection
----mysql_thread_create

```