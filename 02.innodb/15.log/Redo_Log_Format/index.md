
### 插入记录


用户插入的数据行，在内存中的 structure 叫 tuple，在物理上（数据页上）的结构叫 record。record 在数据页物理空间上是乱序存储，通过 record 头部组织成单向链表。这里有两个概念需要说明：

*   cursor record：即（3，C），是待插入记录的前一个记录
*   tnsert record：即（5，E），待插入记录

![](assets/1601799759-4abddb75d83bcf589de4c8b6e227817f.png)

这里再说明一下 INSERT redo 日志的格式。如下图：

*   original offset：在上文已说明，是指 record 真实数据的起始偏移
*   extra info：用意是**对记录压缩**，即在 cursor record 的基础上，对 insert record 进行压缩，大致是如果 cursor record 和 insert record 头 N 个字节相同，则只写入 insert record 从第 N+1 字节（mismatch）到末尾的记录
    

![](assets/1601799759-b7c1eaa72cd7f920741ba5df432bc745.png)

假设插入记录时（5，E），尤其注意其中的 rec\_offset 指的是（3，C）的偏移。这样在 Crash Recovery 时回放到 INSERT redo，即会找到（3，C），将「original rec boay」，即（5，E）作为Record插入到（3，C）之后，InnoDB redo 日志是「物理逻辑」日志，**Physiological**（_**physical-to-a-page logical-within-a-page**，详见 Jim Gray《Transaction Processing》10.3.6小节_ ），可以看到，如果执行两次 INSERT redo，会导致在数据页中有两个（5，E）记录：

*   （3，C）→ （5，E）→ （5，E）  
    

 **InnoDB Redo日志****不具有幂等性**


