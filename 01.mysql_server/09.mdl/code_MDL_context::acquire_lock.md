#1.MDL_context::acquire_lock

```cpp
/** Acquire one lock with waiting for conflicting locks to go away if needed. */
bool
MDL_context::acquire_lock(MDL_request *mdl_request, ulong lock_wait_timeout)
//获取mdl_request锁请求
{...
//首先，第一步：找与锁请求可相容的已经存在的MDL_ticket锁，如果存在则直接使用；找不到则创建新的MDL_ticket对象。
//另外，在找MDL_ticket对象的时候，先看其所属的大类型MDL_lock是否存在（依据MDL_key），不存在则先在MDL_map中创建
//MDL_lock，然后把MDL_ticket对象与MDL_lock类互相注册（互相用指针指向）
    if (try_acquire_lock_impl(mdl_request, &ticket))  
    //“在m_tickets 范围内”找mdl_request锁请求相近的锁；找不到则创建新的
        return TRUE;//找到一个已经存在的锁和申请的锁匹配
    //相近是指MDL_key相同，且申请的锁相容（可升级或与存在的锁相等）；但锁的生命周期可不同（由枚举enum_mdl_duration定义）
    if (mdl_request->ticket)
    //try_acquire_lock_impl()中成功创建了一个锁对象，此锁则可被授予，所以是MDL_ticket对象
    {
        /*We have managed to acquire lock without waiting.
            MDL_lock, MDL_context and MDL_request were updatedaccordingly, so we
            can simply return success.*/
        return FALSE;
    }
//其次，第二步：从这之后的语义是：锁尚不能获取，处于等待状态
    /*Our attempt to acquire lock without waiting has failed.
        As a result of this attempt we got MDL_ticket with m_lock member pointing
        to the corresponding MDL_lock object
        which has MDL_lock::m_rwlock write-locked.*/
    lock= ticket->m_lock;//把MDL_ticket对象与MDL_lock类互相注册（互相用指针指向）后的引用
    lock->m_waiting.add_ticket(ticket);
    //互相注册（互相用指针指向，此处是把ticket作为等待对象加入等待队列的尾部）
//第三步：进行死锁检测
    /*Once we added a pending ticket to the waiting queue,we must ensure that our
    wait slot is empty, so that our lock
        request can be scheduled. Do that in thecritical section formed by the
        acquired write lock on MDL_lock.*/
    m_wait.reset_status();
    if (lock->needs_notification(ticket)) 
    //object类型，非scoped类型；根据锁策略确定（参加11.4.1的第5小节）
        lock->notify_conflicting_locks(this);
…
    will_wait_for(ticket); //ticket处于等待状态，通知死锁检测器等待图是谁
…
    find_deadlock(); //找死锁
//注意如下对于timed_wait()的调用。不能立即获取的锁就需要进行超时等待判断
//即让申请的锁等待一段时间，看释放能够在指定的时间段内，因其他会话释放了锁而得到这样的锁
    if (lock->needs_notification(ticket) || lock->needs_connection_check())
    //object类型，非scoped类型
    {…
        set_timespec(&abs_shortwait, 1);  //要进行超时检测
        wait_status= MDL_wait::EMPTY;     //初始状态
        while (cmp_timespec(&abs_shortwait, &abs_timeout) <= 0)
        {
            /* abs_timeout is far away. Wait a short while and notify locks. */
            wait_status= m_wait.timed_wait(m_owner, &abs_shortwait, FALSE,mdl_
            request->key.get_wait_state_name());
            if (wait_status != MDL_wait::EMPTY)
                break;
…
        }
        if (wait_status == MDL_wait::EMPTY)
            wait_status= m_wait.timed_wait(m_owner, &abs_timeout, TRUE,mdl_
            request->key.get_wait_state_name());
    }
    else   //scoped类型，非object类型
    {
        wait_status= m_wait.timed_wait(m_owner, &abs_timeout, TRUE,mdl_request->
　　　　　key.get_wait_state_name());
    }
    done_waiting_for(); 
    //与will_wait_for(ticket)对应，表明目前不需要进行死锁检测（因为刚刚已完成一次死锁检测）
…
//第四步：死锁检测完成，进行状态检查
//在这之前，ticket因处于等待，可能被其他会话在释放了锁之后通过reschedule_waiters()，而被授予了锁（并发的情况）
    if (wait_status != MDL_wait::GRANTED) //对锁的状态开始进行判断
    {
        lock->remove_ticket(this, m_pins, &MDL_lock::m_waiting, ticket);
        //锁不能被授予，则去掉之前注册到MDL_lock中的ticket对象
…
        MDL_ticket::destroy(ticket);
        //锁不能被授予，则去掉之前注册到MDL_lock中的ticket对象之后销毁它
        switch (wait_status)     //锁不能被授予，对不能被授予的触发因素细化，通知用户原因
        {
        case MDL_wait::VICTIM:   //锁不能被授予原因之一：死锁发生，找到了受害者
            my_error(ER_LOCK_DEADLOCK, MYF(0));
            break;
        case MDL_wait::TIMEOUT: //锁不能被授予原因之二：超时发生
            my_error(ER_LOCK_WAIT_TIMEOUT, MYF(0));
            break;
        case MDL_wait::KILLED:  //锁不能被授予原因之三：申请锁对应的会话线程（用户连接）被killed了
            if (get_owner()->is_killed() == ER_QUERY_TIMEOUT)
                my_error(ER_QUERY_TIMEOUT, MYF(0));
            else
                my_error(ER_QUERY_INTERRUPTED, MYF(0));
            break;
        default:                //锁不能被授予原因之：不可能有其他原因，如果能到这里，则数
                                  据库引擎存在bug
            DBUG_ASSERT(0);
            break;
        }
        return TRUE;
    }
//第五步：不存在死锁，且没有发生超时，则锁被授予
    /*We have been granted our request.  //超时等待判断之后，不能授予锁的情况上面已加处
     理。只剩下锁能被授予的情况
        State of MDL_lock object is already being appropriately updated by
         aconcurrent thread (@sa MDL_lock:reschedule_waiters()).
        So all we need to do is to update MDL_context and MDL_request objects. */
    DBUG_ASSERT(wait_status == MDL_wait::GRANTED);
    m_tickets[mdl_request->duration].push_front(ticket);
    //锁能被授予则注册到锁相关的MDL_context上下文空间里
    mdl_request->ticket= ticket; //锁能被授予也注册到锁请求对象上
…
    return FALSE;
}

```