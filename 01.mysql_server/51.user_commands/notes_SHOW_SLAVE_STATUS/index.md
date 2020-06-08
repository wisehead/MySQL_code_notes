

# [SHOW SLAVE STATUS]

## Read\_Master\_Log\_Pos：

*   当接收到event时，更新Read\_Master\_Log\_Pos  

## Exec\_Master\_Log\_Pos

表示Slave下一次需要从Master binlog读取的位置

*   当事务执行成功commit后， 更新Read\_Master\_Log\_Pos
*   当事务执行失败rollback后，回滚Read\_Master\_Log\_Pos

```plain
/* Update positions on successful commit */
    rli_ptr->set_group_master_log_name(new_group_master_log_name);
    rli_ptr->notify_group_master_log_name_update();
    rli_ptr->set_group_master_log_pos(new_group_master_log_pos);
    rli_ptr->set_group_relay_log_name(new_group_relay_log_name);
    rli_ptr->notify_group_relay_log_name_update();
    rli_ptr->set_group_relay_log_pos(new_group_relay_log_pos);
```

## Seconds\_Behind\_Master

这个值的计算方式为：  

*   如果SQL线程执行完所有的Relay Log  
    Seconds\_Behind\_Master = 0
*   如果SQL线程没有执行完所有的Relay Log，是Slave当前的时间戳与SQL线程执行的event中包含的在Master上产生的时间戳的差

*   current\_time：Slave当前时间
*   event.tv\_sec：event在Master上产生时的时间戳
*   event.exec\_time：event在Master上的执行时间
*   clock\_diff\_with\_master：Slave与Master的时间漂移
    
    Seconds\_Behind\_Master = current\_time -（event.tv\_sec + event.exec\_time）- clock\_diff\_with\_master
    
      
    

event是由Master->Slave I/O Thread->Slave SQL Thread

*   Master->Slave I/O Thread：网络传输延迟
*   Slave I/O Thread->Slave SQL Thread：Slave执行延迟

也就是说，Seconds\_Behind\_Master = 网络传输延迟 + Slave执行延迟

#### Seconds\_Behind\_Master = 0

可能是以下两种原因：

*   SQL线程执行完所有的Relay Log，但网络传输延迟依旧存在（不可忽视）  
    
*   网络传输延迟 + Slave执行延迟 = 0（Slave执行延迟 = 0也就是SQL线程执行完所有的Relay Log），这种情况才是**真正的同步**

#### Seconds\_Behind\_Master != 0

网络传输延迟 + Slave执行延迟 != 0

*   网络传输延迟：**目前尚不清楚如何通过MySQL衡量**
*   Slave执行延迟：可以通过SHOW SLAVE STATUS中的Read\_Master\_Log\_Pos和Exec\_Master\_Log\_Pos衡量

## Retrieved\_Gtid\_Set

```plain
static int queue_event(Master_info* mi,const char* buf, ulong event_len)
{   
    /*
      Add the GTID to the retrieved set before actually appending it to relay
      log. This will ensure that if a rotation happens at this point of time the
      new GTID will be reflected as part of Previous_Gtid set and
      Retrieved_Gtid_Set will not have any gaps.
    */
    if (event_type == GTID_LOG_EVENT)
    {
      global_sid_lock->rdlock();
      old_retrieved_gtid= *(mi->rli->get_last_retrieved_gtid());
      int ret= rli->add_logged_gtid(gtid.sidno, gtid.gno);
      if (!ret)
        rli->set_last_retrieved_gtid(gtid);
      global_sid_lock->unlock();
      if (ret != 0)
      {
        mysql_mutex_unlock(log_lock);
        goto err;
      }
    }
    /* write the event to the relay log */
    ...
}
```

#### Before 5.6.15

Retrieved\_Gtid\_Set的最后一个GTID记录的事务可能不完整

#### **5.6.15 - 5.7.5**

*   如果Executed\_Gtid\_Set不包含last\_retrieved\_gtid
    *   Slave发送给Master ( Retrieved\_Gtid\_Set - last\_retrieved\_gtid ) + Executed\_Gtid\_Set
    *   否则Slave发送给Master ( Retrieved\_Gtid\_Set + Executed\_Gtid\_Set )
*   Master从自身的Executed\_Gtid\_Set刨除Slave发送的GTID集合，余下的GTID的事务认为是Slave没有执行的，都要发送给Slave

#### After 5.7.5

事务边界检测（Transaction Boundary Parser）

