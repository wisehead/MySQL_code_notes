#1.MDL_context::release_lock

```cpp
void MDL_context::release_lock(enum_mdl_duration duration, MDL_ticket *ticket)
{…
if (ticket->m_is_fast_path) {… //如果是快速的访问方式（不针对全局的MDL_key值为GLOBAL和COMMIT）
        /* Don't count singleton MDL_lock objects as unused. */
        if (last_use && ! is_singleton)                 //如果是快速的访问方式，不释
放，只标记为不再被使用的状态，
            mdl_locks.lock_object_unused(this, m_pins);//这样其他的加锁请求可以继续使用
    }
else//把已经授予的MDL_ticket从MDL_lock中去掉，注意MDL_ticket是要被释放的锁对象，对应着本方法的参数
    {
        /*Lock request represented by ticket was acquired using "slow path"
            or ticket was materialized later. We need to use "slow path" release.*/
        //lock对象的remove_ticket()方法会调用reschedule_waiters()以让其他会话有机会获得锁
        //自己（lock对象）不再需要占用锁资源了，就要及时通知别人获取，主动帮助别人的方式更好哦
        lock->remove_ticket(this, m_pins, &MDL_lock::m_granted, ticket);
//lock对象是注册在ticket对象上的MDL_lock
    }
    m_tickets[duration].remove(ticket); //还需要从锁上下文空间MDL_context中把注册过的ticket去掉
…
    MDL_ticket::destroy(ticket);  //当注册去掉后，曾经被授予的锁对象可以被销毁了
…
}
```