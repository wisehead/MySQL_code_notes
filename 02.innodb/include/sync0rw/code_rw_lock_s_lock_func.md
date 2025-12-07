![](./resource/1.png)
![](./resource/2.png)
![](./resource/3.png)

#1.rw_lock_s_lock_func

```cpp
rw_lock_s_lock_func(
    rw_lock_t*    lock,    /*!< in: pointer to rw-lock */
...
{...
    if (!rw_lock_s_lock_low(lock, pass, file_name, line)) {
        //如果加锁不成功，进入等待状态
        /* Did not succeed, try spin wait */
        rw_lock_s_lock_spin(lock, pass, file_name, line);
        //多种机制继续尝试加锁。重要函数详见11.2.1.7节
    }
}
```

#2.call stack

```cpp
rw_lock_s_lock(M)
    ->rw_lock_s_lock_func()
        ->rw_lock_s_lock_low()
            ->rw_lock_lock_word_decr()
```

#3.rw_lock_s_lock_low

```cpp
ibool
rw_lock_s_lock_low(
    rw_lock_t*    lock,    /*!< in: pointer to rw-lock */
...
{
    if (!rw_lock_lock_word_decr(lock, 1, 0)) {
    //注意这里的参数和下面对这些参数值对加锁的影响分析
        /* Locking did not succeed */
        return(FALSE);
    }
...
    return(TRUE);    /* locking succeeded */
}
```

#4.rw_lock_lock_word_dec

```cpp
bool
rw_lock_lock_word_decr(  //加锁操作的底层函数
    rw_lock_t*    lock,        /*!< in/out: rw-lock */
    ulint        amount,      /*!< in: amount to decrement */
    //在原来的锁值上准备减少的数
    lint        threshold)    /*!< in: threshold of judgement */
    //某种锁的边界值。上层rw_lock_s_lock_low()函数传入的threshold值为0
{
#ifdef INNODB_RW_LOCKS_USE_ATOMICS  //如果读写锁被定义为原子操作，定义了这个宏，加锁操
作将使用无锁化（latch-free）的编程技术，使得加锁操作更轻量，推荐在提供了数__sync_bool_
compare_and_swap函数的操作系统上使用无锁化（latch-free）的编程
...
local_lock_word = lock->lock_word;  //保存一份原值，为实现无锁化编程做好准备
    while (local_lock_word > threshold) {  //条件为真，满足加锁条件。threshold值为0，
    表示local_lock_word的值大于0，即可以加锁
        if (os_compare_and_swap_lint(&lock->lock_word, //os_compare_and_swap_lint
        宏使用无锁的原子函数__sync_bool_compare_and_swap实现锁
                         local_lock_word,
local_lock_word - amount)) {  //加锁的操作，是在锁标志位上减去一个数，这里是用减去数后的值
替换原值
            return(true);
        }
        local_lock_word = lock->lock_word;
    }
    return(false);
#else /* INNODB_RW_LOCKS_USE_ATOMICS */   //否则，锁是非原子的
    bool success = false;
    mutex_enter(&(lock->mutex));
    if (lock->lock_word > threshold) {  //条件为真，满足加锁条件。threshold值为0，表示
    local_lock_word的值大于0，即可以加锁
lock->lock_word -= amount;  //加锁的操作，是在锁标志位上减去一个数
        success = true;
    }
    mutex_exit(&(lock->mutex));
    return(success);
#endif /* INNODB_RW_LOCKS_USE_ATOMICS */
}

```