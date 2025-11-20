#1.rw_lock_s_lock_spin
如果加读锁不成功，则需要调用本函数，尝试继续加锁。但是，尝试加锁的机制可单一可丰富，本函数就是一个丰富的、有多种尝试方式的继续加锁机制的函数。



```cpp
/******************************************************************//**
Lock an rw-lock in shared mode for the current thread. If the rw-lock is
locked in exclusive mode, or there is an exclusive lock request waiting,
the function spins a preset time (controlled by srv_n_spin_wait_rounds), waiting
for the lock, before suspending the thread. */
void
rw_lock_s_lock_spin(  //多次尝试加锁，尝试多次加锁的机制比较丰富，值得多研究本函数体的内容
    rw_lock_t*    lock,    /*!< in: pointer to rw-lock */
    ulint        pass,    /*!< in: pass value; != 0, if the lockwill be passed to
    another thread to unlock */
    const char*  file_name, /*!< in: file name where lock requested */
    ulint        line)    /*!< in: line where requested */
{
    ulint        i = 0;    /* spin round count */
    sync_array_t*    sync_arr;  //同步数组，包含有等待队列
...
lock_loop:
    /* Spin waiting for the writer field to become free */
    os_rmb;
    while (i <srv_n_spin_wait_rounds&& lock->lock_word <= 0) {
    //没有超出轮询次数  且  有写锁存在，则延迟会一会后继续探测
        if (srv_spin_wait_delay) {
            ut_delay(ut_rnd_interval(0, srv_spin_wait_delay));     //延迟会一会
        }
        i++;
    }
    if (i >= srv_n_spin_wait_rounds) {  //超出轮询次数，使得本线程睡眠
        os_thread_yield();  //放弃自己（本线程）的时间片
    }
    /* We try once again to obtain the lock */
    if (TRUE == rw_lock_s_lock_low(lock, pass, file_name, line)) { //再尝试一次加锁
        rw_lock_stats.rw_s_spin_round_count.inc();
        return; /* Success */
    } else {
        if (i < srv_n_spin_wait_rounds) {  //没有超出轮询次数，则重新尝试执行本函数主体代码
            goto lock_loop;
        rw_lock_stats.rw_s_spin_round_count.inc();
        sync_cell_t*    cell;
        sync_arr = sync_array_get_and_reserve_cell(lock, RW_LOCK_S, file_name,
        line, &cell);  //因不能获得锁，把自己放入等待队列
        /* Set waiters before checking lock_word to ensure wake-upsignal is sent.
          This may lead to some unnecessary signals. */
        rw_lock_set_waiter_flag(lock);  //设置自己为等待者，直到自己被唤醒
        if (TRUE == rw_lock_s_lock_low(lock, pass, file_name, line)) {
        //如果能够获得锁，则把自己从等待队列中释放出来
            sync_array_free_cell(sync_arr, cell);
            //把自己从等待队列中释放出来
            return; /* Success */
        }
...
        sync_array_wait_event(sync_arr, cell);
        //如果不能够获得锁，产生一个等待事件，并判断是否有死锁发生
        i = 0;
        goto lock_loop;
    }
}

```