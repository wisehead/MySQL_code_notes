#1.MDL_ticket::downgrade_lock

```cpp
//Downgrade an EXCLUSIVE or SHARED_NO_WRITE lock to shared metadata lock.
void MDL_ticket::downgrade_lock(enum_mdl_type new_type)
{…
    /* Only allow downgrade from EXCLUSIVE and SHARED_NO_WRITE. */
    DBUG_ASSERT(m_type == MDL_EXCLUSIVE ||m_type == MDL_SHARED_NO_WRITE);
    //只允许对这两类锁进行降级，m_type表示旧的锁类型
    /* Below we assume that we always downgrade "obtrusive" locks. */
    DBUG_ASSERT(m_lock->is_obtrusive_lock(m_type));//只对“obtrusive”类型的锁降级
…
    m_lock->reschedule_waiters();  //锁被降级的时候，调用reschedule_waiters()可以给别
    的会话以获取锁的机会，能提高并发度
…
}
```