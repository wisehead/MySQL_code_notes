#1.lock_rec_add_to_queue

```cpp
lock_rec_add_to_queue(  //被lock_rec_inherit_to_gap()调用，在原先的锁的基础上加持间隙锁GAP
        LOCK_REC | LOCK_GAP | lock_get_mode(lock),
        //lock_get_mode(lock)是原先锁的粒度和类型，LOCK_GAP是必须加持的类型
        heir_block, heir_heap_no, lock->index,
        lock->trx, FALSE);
```