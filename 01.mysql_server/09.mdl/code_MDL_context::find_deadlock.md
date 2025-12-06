#1.MDL_context::find_deadlock

```cpp
//找出死锁，就是找出一个环。找出以后，就需要打破这个环，从环上摘除一个点，就是受害者点，此时有两种情况：
//一是受害者就是自己；二是受害者上没有访问者
void MDL_context::find_deadlock()  //Try to find a deadlock. This function
produces no errors.
{
    while (1)
    {
        /*The fact that we use fresh instance of gvisitor for eachsearch
          performed by find_deadlock() below is important,
            the code responsible for victim selection relies on this. */
        Deadlock_detection_visitor dvisitor(this);  //this是当前的MDL_context对象，申请锁者。
//从申请锁者出发，找出受害者。在等待图中，申请锁者就是出发点，之后从这个点为起始点，深度遍历等待
图，当再次访问到
//起始点时，就表明存在死锁（有环存在）。下文对MDL_lock::visit_subgraph()方法的分析要用到这一点。
        MDL_context *victim;  //受害者也是一个MDL_context对象
//等待图上不存在来访者，则表明没有死锁。退出循环的条件之一。如果存在死锁则找出受害者，供
get_victim()直接获取受害者
        if (! visit_subgraph(&dvisitor))
        {
            break;/* No deadlocks are found! */
        }
        victim= dvisitor.get_victim(); //否则，存在死锁，需要从当前对象死锁检测访问者
         dvisitor出发找出受害者
        /*Failure to change status of the victim is OK as it meansthat the victim
has received some other message
            and is about to stop its waiting/to break deadlock loop.
            Even when the initiator of the deadlock search ischosen the victim,
we need to set the respective wait
            result in order to "close" it for any attempt toschedule the request.
            This is needed to avoid a possible race duringcleanup in case when
the lock request on which
            the context was waiting is concurrently satisfied. */
        //这一点很重要，被选为受害者的标志就是设置状态为“MDL_wait::VICTIM”。在受害者对应
          的会话内，在获取锁的时候，
//即在MDL_context内执行 MDL_context::acquire_lock()时,就会根据wait_status的值是
       VICITIM执行
//“my_error(ER_LOCK_DEADLOCK, MYF(0));”，让受害者对应的会话给用户报告发生死锁的错误信息。
        (void) victim->m_wait.set_status(MDL_wait::VICTIM);//所以这个标志的设定相当
于并发会话的一个消息通知
        victim->unlock_deadlock_victim();
        if (victim == this) //来访者（本会话）被选为了受害者，是自己造成了死锁。这是退出循
环的另外一个条件
            break;
        /*After adding a new edge to the waiting graph we found that it creates
        a loop (i.e. there is a deadlock).
            We decided to destroythis loop by removing an edge, but not the one
            that we added.
            Since this doesn't guarantee that all loops created by additionof the
            new edge are destroyed,
            we have to repeat the search.*/ //解除死锁的思路，就是找出环中的受害者，破
            坏形成环
    }
}

```