

# [InnoDB（六）：Query Graph]


### 什么是Query Graph？

Query Graph似乎不是一个通用的概念（Query Graph的相关介绍甚少）。文中以InnoDB Purge机制为例，来说明Query Graph的作用

**感性上，Query Graph是InnoDB的线程池实现**

1.  经典的线程池模型中，若干个线程顺序执行队列中的任务
2.  然而在Query Graph中，任务似乎可以用更灵活的形式（二维图的形式，而不只是线性的）被选中执行（暂未十分确定）

目前我倾向认为，经典的线程池功能是Query Graph的一个子集

因此，哪里需要多线程，哪里就可以使用Query Graph（e.g MySQL 5.6的多线程Purge机制）

### “多线程”的Purge机制

InnoDB Purge线程数量的配置项是**innodb\_purge\_threads**，代码中是：

```plain
/* The number of purge threads to use.*/
UNIV_INTERN ulong   srv_n_purge_threads = 1;
```

创建Purge机制核心结构体**purge\_sys**

```plain
trx_purge_sys_create(
/*=================*/
    ulint       n_purge_threads,    /*!< in: number of purge
                        threads */
    ib_bh_t*    ib_bh)          /*!< in, own: UNDO log min
                        binary heap */
{
    // 建立Purge机制的Query Graph
    trx_purge_graph_build(
        purge_sys->trx, n_purge_threads);
}
  
================================================================
  
static
que_t*
trx_purge_graph_build(
/*==================*/
    trx_t*      trx,            /*!< in: transaction */
    ulint       n_purge_threads)    /*!< in: number of purge
                        threads */
{
    ulint       i;
    mem_heap_t* heap;
    que_fork_t* fork;
 
    heap = mem_heap_create(512);
    // 1. fork：purge_sys包含一个"fork node"
    // 2. thr：有多少线程，创建多少thr；从属于一个母节点：fork node
    // 3. purge node：每个thr包含一个"purge node"
    // 4. 每个"purge node"包含若干个需要删除的"DELETE MARK"数据行
    fork = que_fork_create(NULL, NULL, QUE_FORK_PURGE, heap);
    fork->trx = trx;
    for (i = 0; i < n_purge_threads; ++i) {
        que_thr_t*  thr;
 
        thr = que_thr_create(fork, heap);
 
        thr->child = row_purge_node_create(thr, heap);
    }
 
    return(fork);
}
```

在这里，我们可以简单的将Purge流程理解为：

#### **获取任务 - Coordinator Thread**

1.  决定一个可以被“Purge”的事务
2.  事务的第一条Undo日志放入到某一个thr的“purge node”中，第二条Undo日志放入到下一个thr的“purge node”中 ...
3.  决定下一个可以被“Purge”的事务 ...  
      
    ![](assets/1590930742-632752b9158bac827abcf9ccf16ac42b.png)  
      
    

#### 提交任务 - Coordinator Thread

在【获取任务】中处理了N个事务之后...

1.  顺序（Round-Robin）将每个thr**链接到任务队列（srv\_sys->tasks）**中

#### 执行任务 - Coordinator / Worker Thread

在【提交任务】之后，等待下述步骤执行完成、srv\_sys->tasks为空再循环到【获取任务】

对于Coordinator / 每个Worker线程：

1.  从**任务队列（srv\_sys->tasks）**中获取一个thr
2.  该thr从**任务队列（srv\_sys->tasks）**中删除
3.  执行（解析一条Undo日志，在索引中删除数据行）完thr保存的所有Undo日志


