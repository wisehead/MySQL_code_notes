#1.MDL_lock::reschedule_waiters

```cpp
/** Determine waiting contexts which requests for the lock can be satisfied, grant
lock to them and wake them up.
    @note Together with MDL_lock::add_ticket() this method implements fair
     scheduling among requests with the same priority.
        It tries to grant lock from the head of waiters list, while add_ticket()
        adds new requests to the back of this list. */
void MDL_lock::reschedule_waiters()
{...
    MDL_lock::Ticket_iterator it(m_waiting); // m_waiting队列要被迭代
...
    /*
        Find the first (and hence the oldest) waiting request which
        // m_waiting队列中第一个是最老的
        can be satisfied (taking into account priority). Grant lock to it.
        Repeat the process for the remainder of waiters.
        Note we don't need to re-start iteration from the head of the list after
        satisfying the first suitable request
        as in our case all compatible types of requests have the same priority.
    */
    while ((ticket= it++))
    {
        if (can_grant_lock(ticket->get_type(), ticket->get_ctx()))  //满足授予锁的条件
        {
            if (! ticket->get_ctx()->m_wait.set_status(MDL_wait::GRANTED))
            //又能设置为被授予，则不再等待了
            {...
                m_waiting.remove_ticket(ticket);  //等待队列去掉可被授予的低优先级的锁请求
                m_granted.add_ticket(ticket);   //列入被授予锁的队列
                if (is_affected_by_max_write_lock_count())
                //低优先级的锁请求被授予（进入本方法即表明了这一点）
                {
                    if (count_piglets_and_hogs(ticket->get_type()))
                      //但只针对piglet和hog类型
                    {
                        /*
                            Switch of priority matrice might have unblocked some lower-prio
                            locks which are still compatible with the lock type
                            we just have
                            granted (for example, when we grant SNW lock and
                             there are pending
                             requests of SR type). Restart iteration to wake them
                             up, otherwise
                            we might get deadlocks.
                        */
                        it.rewind();
                        continue;
                    }
                }
            }
...
        }
    }
    if (is_affected_by_max_write_lock_count())
    //低优先级的锁请求存在，等待队列中又不包括低优先级的锁请求，则上面所述的计数器重新计数
    {...
        if (m_current_waiting_incompatible_idx == 3)
        //2个计数器都达到了上限，计数器重新计数
        {...
            //等待队列中不再包括低优先级的锁请求（之前的while循环已经把等待队列遍历处理过）
            if ((m_waiting.bitmap() & ~(MDL_OBJECT_HOG_LOCK_TYPES |
                                        MDL_BIT(MDL_SHARED_WRITE) | MDL_BIT(MDL_
                                        SHARED_WRITE_LOW_PRIO))) == 0)
            {
                m_piglet_lock_count= 0;  //计数器重新计数
                m_hog_lock_count= 0;
                m_current_waiting_incompatible_idx= 0;
            }
        }
        else  //2个计数器之一达到了上限，相应的计数器重新计数
        {
            if ((m_waiting.bitmap() & ~MDL_OBJECT_HOG_LOCK_TYPES) == 0)
            {
                m_hog_lock_count= 0;
                m_current_waiting_incompatible_idx&= ~2;
            }
            if ((m_waiting.bitmap() & MDL_BIT(MDL_SHARED_READ_ONLY)) == 0)
            {
                m_piglet_lock_count= 0;
                m_current_waiting_incompatible_idx&= ~1;
            }
        }
    }
}

```