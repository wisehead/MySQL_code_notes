#1.RecLock::lock_alloc

```cpp
lock_t*
RecLock::lock_alloc(  //生成一个记录锁
    trx_t*        trx,    //为指定的事务生成一个记录锁，由此可见记录锁绑定在事务上
    dict_index_t*    index,
    ulint        mode,   //锁的模式
    const RecID& rec_id,//在哪个记录上生成一个记录锁。事务、记录锁、记录三者建立起对应关系
    ulint        size)
{...
    lock_t*    lock;
...
    lock->trx = trx;
    lock->index = index;
    /* Setup the lock attributes */
    lock->type_mode = LOCK_REC | (mode & ~LOCK_TYPE_MASK);  //标明是记录锁
...
    rec_lock.space = rec_id.m_space_id;
    rec_lock.page_no = rec_id.m_page_no; //至此，事务、记录锁、记录三者建立起对应关系
    /* Set the bit corresponding to rec */
    lock_rec_set_nth_bit(lock, rec_id.m_heap_no); //在记录锁上设置本记录对应的锁标志位
...
}
```