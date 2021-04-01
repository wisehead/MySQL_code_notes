#1.rw_pr_rdlock

```cpp

 42 int rw_pr_rdlock(rw_pr_lock_t *rwlock)
 43 {
 44   native_mutex_lock(&rwlock->lock);
 45   /*
 46     The fact that we were able to acquire 'lock' mutex means
 47     that there are no active writers and we can acquire rd-lock.
 48     Increment active readers counter to prevent requests for
 49     wr-lock from succeeding and unlock mutex.
 50   */
 51   rwlock->active_readers++;
 52   native_mutex_unlock(&rwlock->lock);
 53   return 0;
 54 }
```

#2.rw_pr_wrlock

```cpp
 57 int rw_pr_wrlock(rw_pr_lock_t *rwlock)
 58 {
 59   native_mutex_lock(&rwlock->lock);
 60
 61   if (rwlock->active_readers != 0)
 62   {
 63     /* There are active readers. We have to wait until they are gone. */
 64     rwlock->writers_waiting_readers++;
 65
 66     while (rwlock->active_readers != 0)
 67       native_cond_wait(&rwlock->no_active_readers, &rwlock->lock);
 68
 69     rwlock->writers_waiting_readers--;
 70   }
 71
 72   /*
 73     We own 'lock' mutex so there is no active writers.
 74     Also there are no active readers.
 75     This means that we can grant wr-lock.
 76     Not releasing 'lock' mutex until unlock will block
 77     both requests for rd and wr-locks.
 78     Set 'active_writer' flag to simplify unlock.
 79
 80     Thanks to the fact wr-lock/unlock in the absence of
 81     contention from readers is essentially mutex lock/unlock
 82     with a few simple checks make this rwlock implementation
 83     wr-lock optimized.
 84   */
 85   rwlock->active_writer= TRUE;
 86 #ifdef SAFE_MUTEX
 87   rwlock->writer_thread= my_thread_self();
 88 #endif
 89   return 0;
 90 }
 

```