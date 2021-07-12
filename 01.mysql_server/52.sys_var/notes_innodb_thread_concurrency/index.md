

# [innodb\_thread\_concurrency]

innodb\_thread\_concurrency是InnoDB中同时活跃的线程数量（n\_active）的上限：

*   【1】如果innodb\_thread\_concurrency = 0，表示不限制InnoDB中同时活跃的线程数量（MySQL 5.6.23中的默认值为0）
*   【2】如果innodb\_thread\_concurrency > 0，当线程准备进入InnoDB时：
    *   【2.1】如果n\_active = innodb\_thread\_concurrency，线程休眠innodb\_thread\_sleep\_delay，再判断n\_active
    *   【2.2】如果n\_active < innodb\_thread\_concurrency，线程会被分配一定数量“ticket”（每进入一次InnoDB，消耗一个“ticket”），然后进入InnoDB

【注】这里的线程特指外界连接（客户端和Slave）所产生的线程（THD，MySQL默认是thread\_handling = one-thread-per-connection，即连接与线程一一对应）

```plain
/******************************************************************//**
Save some CPU by testing the value of srv_thread_concurrency in inline
functions. */
static inline
void
// 注意trx是THD中的一部分，包含在THD中，与THD一一对应
innobase_srv_conc_enter_innodb(
/*===========================*/
    trx_t*  trx)    /*!< in: transaction handle */
{
    // 如果srv_thread_concurrency > 0
    if (srv_thread_concurrency) {
        if (trx->n_tickets_to_enter_innodb > 0) {
            /* If trx has 'free tickets' to enter the engine left, 
               then use one such ticket */
            // 1. 如果线程的"tickets"数量大于0，则不用去理会当前活跃线程数量是否超出innodb_thread_concurrency
            --trx->n_tickets_to_enter_innodb;
        } else if (trx->mysql_thd != NULL
               && thd_is_replication_slave_thread(trx->mysql_thd)) {
            // 2. 如果是Slave线程（Slave I/O线程，SQL线程，并行复制下的Worker线程）：
            //    1）活跃线程数量没达到上限，进入InnoDB，此处没有分配"tickets"
            //    2）活跃线程数量已达到上限，休眠srv_replication_delay * 1000，然后进入InnoDB
            UT_WAIT_FOR(
                srv_conc_get_active_threads()
                < srv_thread_concurrency,
                srv_replication_delay * 1000);
        }  else {
            // 2. 如果是非Slave线程：
            // 1）活跃线程数量没达到上限，分配"tickets"并进入InnoDB
            // 2）活跃线程数量已达到上限，休眠innodb_thread_sleep_delay，然后重新判断
            srv_conc_enter_innodb(trx);
        }
    }
}
```

这里再详细说说什么叫“进入InnoDB”的线程：

*   MySQL里的连接与THD一一对应，THD里包含了这个连接的所有参数（session）以及连接的SQL等
*   MySQL默认thread\_handling = one-thread-per-connection，连接与线程一一对应

所以连接 / THD / 线程一一对应 

“进入InnoDB”的线程指的就是这个连接（比如某个SQL命令）执行到了InnoDB层（比如在执行write\_row/update\_row等等）

在MySQL/InnoDB中，线程总数就是：mysqld线程 + 用户线程数（客户端/Slave）+InnoDB线程（Master线程 / Purge线程 / Page Cleaner线程...）

innodb\_thread\_concurrency限制的是**执行到InnoDB上的用户线程数（客户端/Slave）**



