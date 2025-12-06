#1.MDL_lock::visit_subgraph

```cpp
/**
    A fragment of recursive traversal of the wait-for graphin search for deadlocks.
    Direct the deadlock visitor to allcontexts that own the lock the current node
    in the wait-forgraph is waiting for.
    As long as the initial node is remembered in the visitor,a deadlock is found
    when the same node is seen twice.*/
bool MDL_lock::visit_subgraph(MDL_ticket *waiting_ticket,MDL_wait_for_graph_
visitor *gvisitor)
{   //waiting_ticket是MDL_context::acquire_lock()里不能被授予锁的处于等待状态的ticket
对象，即新进入等待图的对象
    //gvisitor是死锁检测的发起者，即锁的申请者，在等待图中为第一个要遍历的节点。即waiting_
    ticket所在的MDL_context。
    MDL_ticket *ticket;
    //进入本方法前在MDL_context::acquire_lock()里src_ctx->m_wait值是MDL_wait::EMPTY
    MDL_context *src_ctx= waiting_ticket->get_ctx();
    bool result= TRUE;  //如果result为TRUE，表示有死锁；如下有四种情况，如果存在死锁，则
   不修改result的值
    mysql_prlock_rdlock(&m_rwlock);
    /*Iterators must be initialized after taking a read lock.
     //“fast path”锁之间互斥不会产生死锁，故不考虑
        Note that MDL_ticket's which correspond to lock requests satisfiedon "fast
 path" are not present in m_granted list
        and thuscorresponding edges are missing from wait-for graph.
        It is OK since contexts with "fast path" tickets are not allowed to wait
 for any resource
(they have to convert "fast path" tickets tonormal tickets first) and thus cannot
 participate in deadlock.
        @sa MDL_contex::will_wait_for().*/
    Ticket_iterator granted_it(m_granted); //m_granted是MDL_lock对象上已经被授予的锁列表
    Ticket_iterator waiting_it(m_waiting);//m_waiting是MDL_lock对象上处于等待状态的锁列表
    /*MDL_lock's waiting and granted queues and MDL_context::m_waiting_for member
 are updated by different threads
        when the lock is granted (see MDL_context::acquire_lock() and MDL_
lock::reschedule_waiters()).
        As a result, here we may encounter a situation when MDL_lock dataalready
 reflects the fact
        that the lock was granted butm_waiting_for member has not been updated yet.
        For example, imagine that:
        thread1: Owns SNW lock on table t1.
        thread2: Attempts to acquire SW lock on t1,but sees an active SNW lock.
                         Thus adds the ticket to the waiting queue andsets m_
waiting_for to point to the ticket.
        thread1: Releases SNW lock, updates MDL_lock object togrant SW lock to
 thread2 (moves the ticket for
                         SW from waiting to the active queue).Attempts to acquire
 a new SNW lock on t1,
                         sees an active SW lock (since it is present in theactive queue),
                         adds ticket for SNW lock to the waitingqueue, sets m_
waiting_for to point to this ticket.
        At this point deadlock detection algorithm run by thread1 will see that:
        - Thread1 waits for SNW lock on t1 (since m_waiting_for is set).
        - SNW lock is not granted, because it conflicts with active SW lock
            owned by thread 2 (since ticket for SW is present in granted queue).
        - Thread2 waits for SW lock (since its m_waiting_for has not beenupdated yet!).
        - SW lock is not granted because there is pending SNW lock from thread1.
 Therefore deadlock should exist [sic!].
        To avoid detection of such false deadlocks we need to check the
 "actual"status of the ticket being waited for,
        before analyzing its blockers.We do this by checking the wait status of
 the context which is waitingfor it.
        To avoid races this has to be done under protection ofMDL_lock::m_rwlock lock.
*/
    //进入本方法前在MDL_context::acquire_lock()里src_ctx->m_wait值是MDL_wait::EMPTY
    if (src_ctx->m_wait.get_status() != MDL_wait::EMPTY)
    {
        result= FALSE;//现在，值发生了变化，表明被别的会话修改了状态（发生状态设置的情况参见
       图11-7），但没有死锁
        goto end;
    }
    /*To avoid visiting nodes which were already marked as victims ofdeadlock
           detection (or whose requests
        were already satisfied)Weenter the node only after peeking at its wait status.
        This is necessary to avoid active waiting in a situationwhen previous
        searches for a deadlock
        already selected thenode we're about to enter as a victim (see the
        commentin MDL_context::find_deadlock()
        for explanation why several searchescan be performed for the same wait).
        There is no guarantee that the node isn't chosen a victim while weare
         visiting it but this is OK:
        in the worst case we might do someextra work and one more context might
         be chosen as a victim.*/
    if (gvisitor->enter_node(src_ctx)) //如果搜索深度超过MAX_SEARCH_DEPTH定义的32层，
则认为发生了死锁。另外，存在一个根据权重选受害者的过程，权重小的被选为受害者。相关上下文调用关系
参见图11-8
        goto end;//执行此行代码，表明确认有死锁，所以result的TRUE值不会被修改为FLASE
    /*We do a breadth-first search first -- that is, inspect alledges of the
    current node,
        and only then follow up to the nextnode.In workloads that involve wait-
        for graphloops
        thishas proven to be a more efficient strategy [citation missing].*/
    while ((ticket= granted_it++))  //深度遍历，每次迭代访问初始ticket的next_in_lock
    {
        /* Filter out edges that point to the same node. */
        if (ticket->get_ctx() != src_ctx &&  //与申请锁者（waiting_ticket所在会话）
        不是同一个会话，同一个会话则不必要进行死锁检测了（处于同一个事务无并发竞争）
            ticket->is_incompatible_when_granted(waiting_ticket->get_type()) &&
            //等待申请的锁与已经授予的不相容
            gvisitor->inspect_edge(ticket->get_ctx()))//已经授予锁的节点就是“发起
            者”，表明第二次访问到了自己，有死锁
        {
            goto end_leave_node;
        }
    }
    while ((ticket= waiting_it++))  //深度遍历MDL_lock上的处于等待的锁，查新申请的锁是
    否构成死锁
    {
        /* Filter out edges that point to the same node. */
        if (ticket->get_ctx() != src_ctx && //与申请锁者（waiting_ticket所在会话）不
        是同一个会话
            ticket->is_incompatible_when_waiting(waiting_ticket->get_type()) &&
           //等待申请的锁与早已处于等待锁的不相容
            gvisitor->inspect_edge(ticket->get_ctx()))//已经授予锁的节点就是“发起
           者”，表明第二次访问到了自己，有死锁
        {
            goto end_leave_node;
        }
    }
    /* Recurse and inspect all adjacent nodes. */
    granted_it.rewind();  //重置，重新遍历
    while ((ticket= granted_it++))
    {
        if (ticket->get_ctx() != src_ctx &&
        //与申请锁者（waiting_ticket所在会话）不是同一个会话
            ticket->is_incompatible_when_granted(waiting_ticket->get_type()) &&
            //等待申请的锁与已经授予的不相容
            ticket->get_ctx()->visit_subgraph(gvisitor))
            //水平访问每一个已经得到锁的所在的锁上下文空间（MDL_context）
            //中的已经授予的锁和等待的锁，在此空间中递归搜索（注意是递归）。递归之后的结果
              返回true，则有死锁
        {
            goto end_leave_node;
        }
    }
    waiting_it.rewind(); //重置，重新遍历
    while ((ticket= waiting_it++))
    {
        if (ticket->get_ctx() != src_ctx &&
        //与申请锁者（waiting_ticket所在会话）不是同一个会话
            ticket->is_incompatible_when_waiting(waiting_ticket->get_type()) &&
            //等待申请的锁与早已处于等待锁的不相容
            ticket->get_ctx()->visit_subgraph(gvisitor))
            //水平访问每一个申请锁者的所在的锁上下文空间（MDL_context）
            //中的已经授予的锁和等待的锁，在此空间中递归搜索（注意是递归）。递归之后的结果返回
              true，则有死锁
        {
            goto end_leave_node;
        }
    }
    result= FALSE; //否则，没有发现死锁
end_leave_node:
    gvisitor->leave_node(src_ctx);
end:
    mysql_prlock_unlock(&m_rwlock);
    return result;
}

```