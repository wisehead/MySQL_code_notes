#1.rw_lock_create_func

```cpp
rw_lock_create_func(  //在一个特定的内存位置中创建或初始化一个读写锁对象
rw_lock_t*    lock,/*!< in: pointer to memory */  //传入参数，指向一个读写锁
...
{...
    lock->lock_word = X_LOCK_DECR;  //#defineX_LOCK_DECR0x20000000。给锁赋予一个初值
    lock->waiters = 0;
...
    lock->event = os_event_create(0);          //为一些成员赋值
    lock->wait_ex_event = os_event_create(0);  //为一些成员赋值
    mutex_enter(&rw_lock_list_mutex);  //使用mutex保护rw_lock_list
    ut_ad(UT_LIST_GET_FIRST(rw_lock_list) == NULL
          || UT_LIST_GET_FIRST(rw_lock_list)->magic_n == RW_LOCK_MAGIC_N);
    UT_LIST_ADD_FIRST(rw_lock_list, lock);
    mutex_exit(&rw_lock_list_mutex);
}
```

#2. rw_lock_create

```cpp
rw_lock_create(  //rw_lock_create宏调用了rw_lock_create_func()函数
checkpoint_lock_key, &log_sys->checkpoint_lock,//一个key“checkpoint_lock_key”
对应着一个读写锁“checkpoint_lock”
    SYNC_NO_ORDER_CHECK);
    
    
    
    
/******************************************************************//**
Creates, or rather, initializes an rw-lock object in a specified memory
location (which must be appropriately aligned). The rw-lock is initialized
to the non-locked state. Explicit freeing of the rw-lock with rw_lock_free
is necessary only if the memory block containing it is freed.
if MySQL performance schema is enabled and "UNIV_PFS_RWLOCK" is
defined, the rwlock are instrumented with performance schema probes. */
# ifdef UNIV_DEBUG
#  define rw_lock_create(K, L, level)				\
	rw_lock_create_func((L), (level), #L, __FILE__, __LINE__)
# else /* UNIV_DEBUG */
#  define rw_lock_create(K, L, level)				\
	rw_lock_create_func((L), __FILE__, __LINE__)
# endif	/* UNIV_DEBUG */
```