#1.struct st_thr_lock_data

```cpp
typedef struct st_thr_lock_data {//定义MySQL Server层的锁信息：表对应的锁信息
    THR_LOCK_INFO *owner;  //属主是哪个线程、即隶属于哪个SESSION
    struct st_thr_lock_data *next,**prev;  //前后指针
    struct st_thr_lock *lock;//某个具体的锁，其结构如下
    mysql_cond_t *cond;
    enum thr_lock_type type;//锁的粒度，属于MySQL Server层，上一节详细讨论
    void *status_param;/* Param to status functions */
    void *debug_print_param;
    struct PSI_table *m_psi;
} THR_LOCK_DATA;
```