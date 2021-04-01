#1.sync_array_t

```cpp
/* NOTE: It is allowed for a thread to wait for an event allocated for
the array without owning the protecting mutex (depending on the case:
OS or database mutex), but all changes (set or reset) to the state of
the event must be made while owning the mutex. */

/** Synchronization array */
struct sync_array_t {

        /** Constructor
        Creates a synchronization wait array. It is protected by a mutex
        which is automatically reserved when the functions operating on it
        are called.
        @param[in]      num_cells       Number of cells to create */
        sync_array_t(ulint num_cells)
                UNIV_NOTHROW;

        /** Destructor */
        ~sync_array_t()
                UNIV_NOTHROW;

        ulint           n_reserved;     /*!< number of currently reserved
                                        cells in the wait array */
        ulint           n_cells;        /*!< number of cells in the
                                        wait array */
        sync_cell_t*    array;          /*!< pointer to wait array */
        SysMutex        mutex;          /*!< System mutex protecting the
                                        data structure.  As this data
                                        structure is used in constructing
                                        the database mutex, to prevent
                                        infinite recursion in implementation,
                                        we fall back to an OS mutex. */
        ulint           res_count;      /*!< count of cell reservations
                                        since creation of the array */
        ulint           next_free_slot; /*!< the next free cell in the array */
        ulint           first_free_slot;/*!< the last slot that was freed */
};
```

#2.辅助结构

```cpp
辅助结构
InnoDB 同步机制中，还有很多使用的辅助结构，他们的作用主要是为了监控方便和死锁的预防和检测。这里主要介绍sync array, sync thread level array 和srv_error_monitor_thread。

sync array 主要的数据结构是sync_array_t，可以把他理解为一个数据，数组中的元素为sync_cell_t。当一个锁（InnoDB 自旋互斥锁或者InnoDB 读写锁，下同）需要发生os_event_wait等待时，就需要在sync array 中申请一个sync_cell_t 来保存当前的信息，这些信息包括等待锁的指针（便于死锁检测），在哪一个文件以及哪一行发生了等待（也就是mutex_enter, rw_lock_s_lock 或者rw_lock_x_lock 被调用的地方，只在debug 模式下有效），发生等待的线程（便于死锁检测）以及等待开始的时间（便于统计等待的时间）。当锁释放的时候，就把相关联的sync_cell_t 重置为空，方便复用。sync_cell_t 在sync_array_t 中的个数，是在初始化同步模块时候就指定的，其个数一般为OS_THREAD_MAX_N，而OS_THREAD_MAX_N 是在InnoDB 初始化的时候被计算，其包括了系统后台开启的所有线程，以及max_connection 指定的个数，还预留了一些。由于一个线程在某一个时刻最多只能发生一个锁等待，所以不用担心sync_cell_t不够用。从上面也可以看出，在每个锁进行等待和释放的时候，都需要对sync array操作，因此在高并发的情况下，单一的sync array 可能成为瓶颈，在MySQL 5.6中，引入了多sync array, 个数可以通过innodb_sync_array_size 进行控制，这个值默认为1，在高并发的情况下，建议调高。

InnoDB 作为一个成熟的存储引擎，包含了完善的死锁预防机制和死锁检测机制。在每次需要锁等待时，即调用os_event_wait之前，需要启动死锁检测机制来保证不会出现死锁，从而造成无限等待。在每次加锁成功（lock_word 递减后，函数返回之前）时，都会启动死锁预防机制，降低死锁出现的概率。当然，由于死锁预防机制和死锁检测机制需要扫描比较多的数据，算法上也有递归操作，所以只在debug 模式下开启。

```