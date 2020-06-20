---
title: MySQL源码学习——MDL字典锁 - 心中无码 - 博客园
category: default
tags: 
  - www.cnblogs.com
created_at: 2020-05-19 16:50:37
original_url: https://www.cnblogs.com/nocode/archive/2011/12/15/2289507.html
---

## [MySQL源码学习——MDL字典锁](https://www.cnblogs.com/nocode/archive/2011/12/15/2289507.html)

2011-12-15 22:34  [心中无码](https://www.cnblogs.com/nocode/)  阅读(2491)  评论(7)  [编辑](https://i.cnblogs.com/EditPosts.aspx?postid=2289507)  [收藏](javascript:)

*   # 什么是MDL
    

         MDL，Meta Data lock，元数据锁，一般称为**字典锁**。字典锁与数据锁相对应。字典锁是为了保护数据对象被改变，一般是一些DDL会对字典对象改变，如两个TX，TX1先查询表，然后TX2试图DROP，字典锁就会lock住TX2，知道TX1结束（提交或回滚）。数据锁是保护表中的数据，如两个TX同时更新一行时，先得到row lock的TX会先执行，后者只能等待。

*   # MDL的设计目标
    

字典锁在设计的时候是为了数据库对象的元数据。到达以下3个目的。

1\. 提供对并发访问内存中字典对象缓存(table definatin cache，TDC)的保护。这是系统的内部要求。

2\. 确保DML的并发性。如TX1对表T1查询，TX2同是对表T1插入。

3\. 确保一些操作的互斥性，如DML与大部分DDL(ALTER TABLE除外)的互斥性。如TX1对表T1执行插入，TX2执行DROP TABLE，这两种操作是不允许并发的，故需要将表对象保护起来，这样可以保证binlog逻辑的正确性。（貌似之前的版本存在字典锁是语句级的，导致binlog不合逻辑的bug。）

*   # 支持的锁类型
    

        数据库理论中的基本锁类型是S、X，意向锁IS、IX是为了层次上锁而引入的。比如要修改表中的数据，可能先对表上一个表级IX锁，然后再对修改的数据上一个行级X锁，这样就可以保证其他试图修改表定义的事物因为获取不到表级的X锁而等待。

        MySQL中将字典锁的类型根据不同语句的功能，进一步细分，**细分的依据是对字典的操作和对数据的操作**。细分的好处是能在一定程度上提高并发效率，因为如果只定义X和S两种锁，必然导致兼容性矩阵的局限性。MySQL不遗余力的定义了如下的锁类型。

<table style="width: 493px;" border="1" cellspacing="0" cellpadding="2"><tbody><tr><td valign="top" width="245">名称</td><td valign="top" width="246">意义</td></tr><tr><td valign="top" width="245"><p>MDL_INTENTION_EXCLUSIVE</p></td><td valign="top" width="246"><p>意向排他锁，只用于范围上锁</p></td></tr><tr><td valign="top" width="245"><p>MDL_SHARED</p></td><td valign="top" width="246"><p>共享锁，用于访问字典对象，而不访问数据。</p></td></tr><tr><td valign="top" width="245"><p>MDL_SHARED_HIGH_PRIO</p></td><td valign="top" width="246"><p>只访问字典对象（如DESC TABLE）</p></td></tr><tr><td valign="top" width="245"><p>MDL_SHARED_READ</p></td><td valign="top" width="246"><p>共享读锁，用于读取数据（如select）</p></td></tr><tr><td valign="top" width="245"><p>MDL_SHARED_WRITE</p></td><td valign="top" width="246"><p>共享写锁，用于修改数据（如update）</p></td></tr><tr><td valign="top" width="245"><p>MDL_SHARED_NO_WRITE</p></td><td valign="top" width="246"><p>共享非写锁，允许读取数据，阻塞其他TX修改数据（如alter table）</p></td></tr><tr><td valign="top" width="245"><p>MDL_SHARED_NO_READ_WRITE</p></td><td valign="top" width="246"><p>用于访问字典，读写数据</p><p>不允许其他TX读写数据</p></td></tr><tr><td valign="top" width="245"><p>MDL_EXCLUSIVE</p></td><td valign="top" width="246"><p>排他锁，可以修改字典和数据</p></td></tr></tbody></table>

          可以看到MySQL在ALTER TABLE的时候还是允许其他事务进行读表操作的。需要注意的是读操作的事物需要在ALTER TABLE获取MDL\_SHARED\_NO_WRITE锁之后，否则无法并发。这种应用场景应该是对一个较大的表进行ALTER时，其他事物仍然可以读，并发性得到了提高。

*   # 锁的兼容性
    

          锁的兼容性就是我们经常看到的那些兼容性矩阵，X和S必然互斥，S和S兼容。MySQL根据锁的类型我们也可以知道其兼容矩阵如下：

<table style="width: 425px;" border="1" cellspacing="0" cellpadding="2"><tbody><tr><td valign="top" width="52">&nbsp;</td><td valign="top" width="36">IX</td><td valign="top" width="44">S</td><td valign="top" width="44">SH</td><td valign="top" width="44">SR</td><td valign="top" width="44">SW</td><td valign="top" width="44">SNW</td><td valign="top" width="61">SNRW</td><td valign="top" width="54">X</td></tr><tr><td valign="top" width="52">IX</td><td valign="top" width="36">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="61">1</td><td valign="top" width="54">1</td></tr><tr><td valign="top" width="52">S</td><td valign="top" width="36">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="61">1</td><td valign="top" width="54">0</td></tr><tr><td valign="top" width="52">SH</td><td valign="top" width="36">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="61">1</td><td valign="top" width="54">0</td></tr><tr><td valign="top" width="52">SR</td><td valign="top" width="36">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="61">0</td><td valign="top" width="54">0</td></tr><tr><td valign="top" width="52">SW</td><td valign="top" width="36">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">0</td><td valign="top" width="61">0</td><td valign="top" width="54">0</td></tr><tr><td valign="top" width="52">SNW</td><td valign="top" width="36">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">0</td><td valign="top" width="44">0</td><td valign="top" width="61">0</td><td valign="top" width="54">0</td></tr><tr><td valign="top" width="52">SNRW</td><td valign="top" width="36">1</td><td valign="top" width="44">1</td><td valign="top" width="44">1</td><td valign="top" width="44">0</td><td valign="top" width="44">0</td><td valign="top" width="44">0</td><td valign="top" width="61">0</td><td valign="top" width="54">0</td></tr><tr><td valign="top" width="52">X</td><td valign="top" width="36">1</td><td valign="top" width="44">0</td><td valign="top" width="44">0</td><td valign="top" width="44">0</td><td valign="top" width="44">0</td><td valign="top" width="44">0</td><td valign="top" width="61">0</td><td valign="top" width="54">0</td></tr></tbody></table>

         1代表兼容，0代表不兼容。你可能发现X和IX竟然兼容，没错，其实这里的IX已经不是传统意义上的IX，这个IX是用在范围锁上，所以和X锁不互斥。

*   # 数据结构
    

涉及到的和锁相关的数据结构主要是如下几个：

MDL_context：字典锁上下文。包含一个事物所有的字典锁请求。

MDL_request：字典锁请求。包含对某个对象的某种锁的请求。

MDL\_ticket：字典锁排队。MDL\_request就是为了获取一个ticket。

MDL_lock：锁资源。一个对象全局唯一。可以允许多个可以并发的事物同时获得。

涉及到的源码文件主要是sql/mdl.cc

*   # 锁资源
    

         锁资源在系统中是**共享的**，即全局的，存放在static MDL\_map mdl\_locks;的hash链表中，对于数据库中的一个对象，其hashkey必然是唯一的，对应一个锁资源。多个事务同时对一张表操作时，申请的lock也是同一个内存对象。获取mdl\_locks中的lock需要通过全局互斥量保护起来mysql\_mutex\_lock(&m\_mutex); m\_mutex是MDL\_map的成员。

*   # 上锁流程
    

        一个会话连接在实现中对应一个THD实体，一个THD对应一个MDL\_CONTEXT，表示需要的mdl锁资源，一个MDL\_CONTEXT中包含多个MDL\_REQUEST，一个MDL\_REQUEST即是对一个对象的某种类型的lock请求。每个mdl_request上有一个ticket对象，ticket中包含lock。

上锁的也就是根据MDL_REQUEST进行上锁。

```plain
Acquire_lock:
    if (mdl_request contains the needed ticket )
    return ticket;
    End if;
    Create a ticket;
    If (!find lock in lock_sys)
    Create a lock;
    End if
    If (lock can be granted to mdl_request)
    Set lock to ticket;
    Set ticket to mdl_request;
    Else
    Wait for lock
End if
```

          稍微解释下，首先是在mdl_request本身去查看有没有相等的或者stronger的ticket，如果存在，则直接使用。否则创建一个ticket，查找上锁对象对应的lock，没有则创建。检查lock是否可以被赋给本事务，如果可以直接返回，否则等待这个lock；

*   # 锁等待与唤醒
    

        字典对象的锁等待是发生在两个事物对同一对象上不兼容的锁导致的。当然，由于lock的唯一性，先到先得，后到的只能等待。

         如何判断一个lock是否可以grant给一个TX？这需要结合lock结构来看了，lock上有两个成员，grant和wait，grant代表此lock允许的事物都上了哪些锁，wait表示等待的事务需要上哪些锁。其判断一个事物是否可以grant的逻辑如下：

```plain
If(compatible(lock.grant, tx.locktype))
    If (compatible(lock.wait, tx.locktype))
    return can_grant;
    End if
End if
```

         即首先判断grant中的锁类型和当前事务是否兼容，然后判断wait中的锁类型和当前事务是否兼容。细心的话，会想到，wait中的锁类型是不需要和当前事务进行兼容性比较的，这是不是说这个比较是多余的了？其实也不是，因为wait的兼容性矩阵和上面的矩阵是不一样的，wait的兼容性矩阵感觉是在DDL等待的情况下，防止DML继续进来（wait矩阵就不写出来了，大家可以去代码里看下）。

比如：

TX1                                                      TX2                                                       TX3

SELECT T1

                                                             DROP  T1

                                                                                                                              SELECT T1

        这时候TX2会阻塞，TX3也会阻塞，被TX2阻塞，也就是说被wait的事件阻塞了，这样可能就是为了保证在DDL等待时，禁止再做DML了，因为在DDL面前，DML显得确实不是那么重要了。

          如何唤醒被等待的事务呢？比如唤醒TX2，当TX1结束时，会调用release\_all\_locks\_for\_name，对被锁住的事务进行唤醒，具体操作封装在**reschedule_waiters**函数中，重置等待时间的标记位进行唤醒,重点代码如下:

```plain
if (can_grant_lock(ticket->get_type(), ticket->get_ctx()))
    {
      if (! ticket->get_ctx()->m_wait.set_status(MDL_wait::GRANTED))
      {
        /*
          Satisfy the found request by updating lock structures.
          It is OK to do so even after waking up the waiter since any
          session which tries to get any information about the state of
          this lock has to acquire MDL_lock::m_rwlock first and thus,
          when manages to do so, already sees an updated state of the
          MDL_lock object.
        */
        m_waiting.remove_ticket(ticket);
        m_granted.add_ticket(ticket);
    }
```

      今天把mdl系统总体上看了一下，对锁的请求、等待以及唤醒有了初步了解。并发性的问题是最难调试的，大家如果想做锁方面的实验，可以利用VS调试中的**冻结线程**的功能，这样就可以确保并发情况控制完全按照你设计思路去呈现。

应TB_ZQL同学的要求，现加上MDL DEADLOCK检查的代码分析。

## MDL死锁检查

何为死锁？死锁是计算机里面比较普遍的现象，只要存在多个个体竞争共有资源时，而造成互相等待的现象， 就是死锁，如个体A获取了资源S1并一直占有，个体B获取了资源S2并一直占有，然后个体A想获取S2，个体B 想获取S1，这样A需要等待B释放S2，而B同时需要等待A释放S1，这样A等B，B等A，如果不进行干预，那么A和B 就这么一直处于互相等待的状态。

所以这时候就需要进行死锁检查,如何进行死锁检查？死锁的形成其实是形成了环状等待，去除死锁，只需要切断环中 的一个节点即可，如上面的示例，终止A或者终止B都能使另外一方获取需要的资源，而继续运行，对于被终止的对象， 对不起了，你只能重做了。

我们来看下MDL的死锁检查。里面用到的类和结构体就不说明了，先给出其函数调用的层次关系。

```plain
>MDL_context::acquire_lock
| >MDL_context::find_deadlock 
| | >MDL_context::visit_subgraph
| | | >MDL_ticket::accept_visitor
| | | | >MDL_lock::visit_subgraph
```

事实上，主要的检查函数是lock的visit_subgraph，这里看下这个函数的实现。  

[![复制代码](assets/1589878237-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
bool MDL_lock::visit_subgraph(MDL_ticket *waiting_ticket,
                              MDL_wait_for_graph_visitor *gvisitor)
{
  MDL_ticket *ticket;
  MDL_context *src_ctx= waiting_ticket->get_ctx();
  bool result= TRUE;

  mysql_prlock_rdlock(&m_rwlock);

  /* Must be initialized after taking a read lock. */
  Ticket_iterator granted_it(m_granted);
  Ticket_iterator waiting_it(m_waiting);

  if (gvisitor->enter_node(src_ctx))
    goto end;
    
  while ((ticket= granted_it++))
  {
    /* Filter out edges that point to the same node. */
    if (ticket->get_ctx() != src_ctx &&
        ticket->is_incompatible_when_granted(waiting_ticket->get_type()) &&
        gvisitor->inspect_edge(ticket->get_ctx()))
    {
      goto end_leave_node;
    }
  }

  while ((ticket= waiting_it++))
  {
    /* Filter out edges that point to the same node. */
    if (ticket->get_ctx() != src_ctx &&
        ticket->is_incompatible_when_waiting(waiting_ticket->get_type()) &&
        gvisitor->inspect_edge(ticket->get_ctx()))
    {
      goto end_leave_node;
    }
  }

  /* Recurse and inspect all adjacent nodes. */
  granted_it.rewind();
  while ((ticket= granted_it++))
  {
    if (ticket->get_ctx() != src_ctx &&
        ticket->is_incompatible_when_granted(waiting_ticket->get_type()) &&
        ticket->get_ctx()->visit_subgraph(gvisitor))
    {
      goto end_leave_node;
    }
  }

  waiting_it.rewind();
  while ((ticket= waiting_it++))
  {
    if (ticket->get_ctx() != src_ctx &&
        ticket->is_incompatible_when_waiting(waiting_ticket->get_type()) &&
        ticket->get_ctx()->visit_subgraph(gvisitor))
    {
      goto end_leave_node;
    }
  }

  result= FALSE;

end_leave_node:
  gvisitor->leave_node(src_ctx);

end:
  mysql_prlock_unlock(&m_rwlock);
  return result;

}
```

[![复制代码](assets/1589878237-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

上面这段代码的返回值如果是TRUE则表示存在死锁，同时这段代码从两个方向找死锁，一个是 granted，一个是waiting，granted用于判断锁的授予是否形成了环，当然这里的锁不是指同一个锁，而是 指锁所属于的ctx，waiting用于判断锁的等待是否形成了环，这两个应该是死锁检查的不同方向，应该对于 某一个死锁两个方向都可以成功找到。

这是一个递归函数，看递归函数的基本就是找到函数的出口，显然函数的出口是inspect\_edge函数，gvisitor在进行 死锁检查的开始会设置m\_start_node，这个值在整个检查过程中始终不变，就是为了遍历的过程中再次遇到这个值， 这就表示形成了环路，无论是等待环，还是granted环。

最后需要说明的是如何选出victim，即应该牺牲哪一个事务，使得死锁环断裂，从而破除死锁，因为随便破坏环中的任意 一个节点都能达到这种效果，那就需要看哪个节点最不重要了，那它就活该倒霉。具体的判断函数如下:

[![复制代码](assets/1589878237-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

```plain
void
Deadlock_detection_visitor::opt_change_victim_to(MDL_context *new_victim)
{
  if (m_victim == NULL ||
      m_victim->get_deadlock_weight() >= new_victim->get_deadlock_weight())
  {
    /* Swap victims, unlock the old one. */
    MDL_context *tmp= m_victim;
    m_victim= new_victim;
    m_victim->lock_deadlock_victim();
    if (tmp)
      tmp->unlock_deadlock_victim();
  }
}

uint MDL_ticket::get_deadlock_weight() const
{
  return (m_lock->key.mdl_namespace() == MDL_key::GLOBAL ||
          m_type >= MDL_SHARED_NO_WRITE ?
          DEADLOCK_WEIGHT_DDL : DEADLOCK_WEIGHT_DML);
}

enum enum_deadlock_weight
  {
    DEADLOCK_WEIGHT_DML= 0,
    DEADLOCK_WEIGHT_DDL= 100
  };
```

[![复制代码](assets/1589878237-48304ba5e6f9fe08f3fa1abda7d326ab.gif)](javascript: "复制代码")

可以看出有一个计算事务权重的函数，这时候就看这个事务的类型，DDL事务的权重明显高于DML，即如果DML和DDL形成死锁， 那么DML事务将被kick。

踏着落叶，追寻着我的梦想。转载请注明出处

[好文要顶](javascript:) [关注我](javascript:) [收藏该文](javascript:) [![](assets/1589878237-3212f7b914cc9773fb30bbf4656405fc.png)](javascript: "分享至新浪微博") [![](assets/1589878237-cb7153d1c13a5d9aef10ebab342f6f71.png)](javascript: "分享至微信")

[![](assets/1589878237-1b048b1e4cd8b71be0b22f8d511280e7.jpg)](https://home.cnblogs.com/u/nocode/)

[心中无码](https://home.cnblogs.com/u/nocode/)  
[关注 \- 2](https://home.cnblogs.com/u/nocode/followees/)  
[粉丝 \- 86](https://home.cnblogs.com/u/nocode/followers/)

[+加关注](javascript:)

7

0

[«](https://www.cnblogs.com/nocode/archive/2011/12/12/2285350.html) 上一篇： [MySQL源码学习——DBUG调试](https://www.cnblogs.com/nocode/archive/2011/12/12/2285350.html "发布于 2011-12-12 22:10")  
[»](https://www.cnblogs.com/nocode/archive/2011/12/26/2302343.html) 下一篇： [CSDN密码库窥视各大数据库性能](https://www.cnblogs.com/nocode/archive/2011/12/26/2302343.html "发布于 2011-12-26 17:30")

*   分类 [MySQL Code Trace](https://www.cnblogs.com/nocode/category/293180.html)

---------------------------------------------------


原网址: [访问](https://www.cnblogs.com/nocode/archive/2011/12/15/2289507.html)

创建于: 2020-05-19 16:50:37

目录: default

标签: `www.cnblogs.com`

