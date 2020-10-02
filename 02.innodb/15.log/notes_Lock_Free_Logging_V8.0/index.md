

# [InnoDB 8.0：Lock-free Logging]


## 前言

### Flush List介绍

## ![](assets/1601638654-ec4d2b01bb54034a6d34c015435e9a50.png)

  

一些说明，

*   Page：内存结构记录了oldest\_modification，自从载入Buffer Pool后修改该Page的第一个Redo日志的LSN（即是最小的LSN）
*   Flush List：按照oldest\_modification排序，沿着链表头方向，Page的oldest\_modification增大（头插法）
*   Page Cleaner线程：从Flush List尾部开始遍历，依次将Page刷写入磁盘中

同一个Page可能被修改多次（如图中，Page5被LSN=6和LSN=10的两条日志修改过）：

*   那么Page Cleaner刷写Page5时，会同时LSN=6和LSN=10两条日志的_**“变更”**_持久化=>导致Redo Log中暂时的出现“未持久化变更“的“日志空洞”
*   Checkpoint“参考”oldest\_modification，只能取checkpoint\_lsn=6

### 约束

【Flush-List的顺序约束】MTR1（LSN1和Page1）和 MTR2（LSN2和Page2）：

*   如果LSN1<LSN2，Page1 先于 Page2 插入 Flush-List

这个约束，即 Flush-List 的有序性，是 InnoDB Checkpoint 机制的前提。否则，Checkpoint 无法正确的向前推进：

【例1】Flush-List不再有序：

  

![](assets/1601638654-652e3c0c3f6e109448234c90928e45b4.png)

  

### MySQL 8.0 的优化点

这里主要介绍和分析 MySQL 8.0 的两个优化点：

*   【Redo  Log 】 “串行写入”的 Log Buffer  =>  “并行写入”的 Log Buffer
*   【Buffer Pool】 “严格顺序”的 Flush List   =>  “宽松顺序”的 Flush List

【附】MTR提交时的步骤

![](assets/1601638654-863f5ae701133529e9a89ec22f1a97b1.png)

Log Buffer为串行写入：所有的用户线程去争抢一个 “log buffer mutex”（代码中为 log\_sys->mutex）

![](assets/1601638654-abc4379657f12085772e2e14461a4e90.png)

### Link\_buf --- "无锁"的数据结构

Link\_buf是一个环形数组，数组的每一个位置称作一个Slot：

*   每个Slot有两个属性：位置（index）和值（value）
*   Link\_buf的大小定义为“Slot的数量”，_**记为L**_
*   每个Slot的值**原子地**更新
*   每个Slot的值初始化为0，当在位置idx写入值n：表示（idx，idx+n）这个区间被“使用”
*   一个独立的线程通过由数组头->尾的遍历，来追踪连续被“使用”的最大可达区间（具体追踪方法，见下节）
*   记可达的连续区间的右端点（高水位），_**记为M**_

  

        ![](assets/1601638654-368d20d9e9bc46a31b5d5d9003b12957.png)

```plain
/** @@Link_buf Concurrent data structure, which allows to track concurrently
performed operations which locally might be dis-ordered.
 
This data structure is informed about finished concurrent operations
and tracks up to which point in a total order all operations have
been finished (there are no holes).
 
It also allows to limit the last period in which there might be holes.
These holes refer to unfinished concurrent operations, which preceed
in the total order some operations that are already finished.
 
Threads might concurrently report finished operations (lock-free).
 
Threads might ask for maximum currently known position in total order,
up to which all operations are already finished (lock-free).
 
Single thread might track the reported finished operations and update
maximum position in total order, up to which all operations are done.
 
You might look at current usages of this data structure in log0buf.cc.
*/
```

## 并发写入的 Log Buffer

Redo日志（Log Buffer + Log Files）系统可以抽象为生产者-消费者模型：

*   多个生产者：用户线程
*   一个消费者：Crash Recovery时的主线程

因此需要保证Redo日志系统（Log Buffer + Log Files）的线程安全

#### 【MySQL < 8.0】线程安全的设计：

什么是Log Buffer的线程安全？

*   MTR提交时（拷贝日志到公共Log Buffer），日志全部地，连续地拷贝至Log Buffer相应的位置；MTR内的日志拷贝至公共Log Buffer中也是连续的，不会在以后被其余的MTR日志覆盖

在MTR将私有Redo日志提交到公共Log Buffer时：

*   **互斥地**获得start\_lsn（写入到公共Log Buffer的位置）
*   **互斥地“**拷贝”

#### 【MySQL >= 8.0】线程安全的设计：

在MTR将私有Redo日志提交到公共Log Buffer时：

*   **互斥地**获得start\_lsn（写入到公共Log Buffer的位置），std::atomic实现
*   **并发地“**拷贝”

具体地，采用**无锁的环形数组_recent\_written（Link\_buf类型_）**实现（Log Buffer是环形写入的）。流程为：

1.  每次准备拷贝日志到Log Buffer时，先向Log Buffer申请一段“预留区间”（start\_lsn，end\_lsn）
    
    ```plain
    Log_handle log_buffer_reserve(log_t &log, size_t len) {
      /* Reserve space in sequence of data bytes: */
      const sn_t start_sn = log.sn.fetch_add(len);
      /* Headers in redo blocks are not calculated to sn values: */
      // 申请的预留区间范围（start_sn, end_sn）
      const sn_t end_sn = start_sn + len;
      /* Translate sn to lsn (which includes also headers in redo blocks): */
      handle.start_lsn = log_translate_sn_to_lsn(start_sn);
      handle.end_lsn = log_translate_sn_to_lsn(end_sn);
     
      // sn_limit_for_end是当前Log Buffer最大可写入的LSN
      // sn_limit_for_end = log_translate_lsn_to_sn(write_lsn) + buf_size - extra_free;
      // write_lsn是已写入到磁盘文件缓存的最大LSN（不要求Fsync）
      if (unlikely(end_sn > log.sn_limit_for_end.load())) {
        log_wait_for_space_after_reserving(log, handle);
      }
    }
    ```
    
    【例2】假设Log Buffer容量（buf\_size）是50 Byte，刚刚把一段日志（10，20）从Log Buffer中刷入文件Cache中（尚未保证sync）：
    
    *   flushed\_lsn = 10：直到LSN=10的日志持久化到了磁盘文件中
    *   write\_lsn=20：直到LSN=20的日志已写入到文件缓存中
    *   sn\_limit\_for\_end = write\_lsn + buf\_size = 20 + 50 = 70：表示如果当前Log Buffer写满了的话（从write\_lsn写到尾部，在从头部开始写到“write\_lsn的位置”），最大的LSN就是70  
          
        ![](assets/1601638654-462d5c3ac5932f1d4074bc0e0a023147.png)
2.  在_**recent\_written**_中位置（start\_lsn/_**recent\_written.L**_）写入值（end\_lsn - start\_lsn）,表示一个从start\_lsn指向end\_lsn的“Link”

【总结】_**recent\_written****记录了“有哪些日志已经写入了Log Buffer中”**_

这个流程记为_**第一阶段**_

【1】Log Buffer类似这样（是环形数组，图中未表示）

    ![](assets/1601638654-7aa46893a52f1c4a015fed4e3968abf8.png)

【2】当我们又写入了一批日志

![](assets/1601638654-393202a11121d4b7a7e11a43d76276d4.png)

【3】触发**特定的线程（log\_writter）**扫描**_recent\_written_**，更新M

   ![](assets/1601638654-9fb7c0552ed85799a6c1445d56cd7a97.png)

【4】异步地更新_**recent\_written**_的M，赋值给buf\_ready\_for\_write\_lsn，表示Log Buffer中连续的可以被写入磁盘的LSN的最大值

   ![](assets/1601638654-ae75eb2fefffb963d89f5fe56657483d.png)

## “宽松顺序”（Relax-Order）的Flush-List

  

            ![](assets/1601638654-c431cc2fcc06a2df6dae2fba790a787b.png)

### MySQL 5.6/5.7

**红色部分**保证了【Flush-List约束】

**紫色部分**保证了并发插入Flush-List的线程安全（对链表Prev/Next指针的修改）

```plain
假设两个MTR：
MTR1：LSN1 / Page1
MTR2：LSN2 / Page2
 
如果LSN1 < LSN2，说明MTR1持有log_sys.mutex，在释放log_sys.mutex之前再获取flush_order.mutex，可以保证Page1先于Page2插入Flush-List
```

### MySQL 8.0

MySQL 8.0去掉了flush\_order.mutex，**不再保证Flush-List全局有序**；取而代之的是只保证Flush-List局部有序

类似于Log Buffer使用_**recent\_written**_，这里也使用一个Link\_buf数组，叫做_**recent\_closed**_

流程为：

1.  在_**第一阶段**_完成之后，需要将日志（start\_lsn，end\_lsn）产生的脏页加入到Flush-List中
2.  当_**start\_lsn -** **_recent_\_closed.M**_ > **_recent\_closed.L_**时，阻塞；否则，向下执行  
      
    【例3】recent\_closed大小（capacity）是50，M是20，MTR提交时，产生的日志start\_lsn=80  
                 80-20>50，意味着80%50>20，那么MTR在此处阻塞，否则将写入到已被预留的Slot（图中的红色区域） !!  
      
    ![](assets/1601638654-96a649365d94b8ad95fdd2b21c389c4f.png)  
      
    
3.  将日志（start\_lsn，end\_lsn）产生的脏页加入到Flush-List中
4.  在_**recent\_closed**_中位置（start\_lsn/_**recent\_closed.L**_）写入值（end\_lsn - start\_lsn）,表示一个从start\_lsn指向end\_lsn的“Link”
5.  Log\_closer线程异步的更新**_recent\_closed_**的M

【总结】_**recent\_closed记录了“有哪些日志产生的脏页已经加入到Flush-List中”**_

![](assets/1601638654-3bdab9d04da1fe74af283bebc737e136.png)

【Flush-List的顺序约束-8.0】MTR1（LSN1和Page1）和MTR2（LSN2和Page2）：

*   【1】若0 < LSN1 - LSN2 < L，Page1和Page2在Flush-List中无必然的先后关系
*   【2】若LSN1 - LSN2 > L，Page2比Page1先插入到Flush-List中

```plain
【1】略
【2】反证法；假设Page1比Page2先插入到Flush-List中
Page1插入到Flush-List时，有：
    LSN1 - M < L
又因为Page2未插入Flush-List, 有：
    M <= LSN2
所以：
    L > LSN1 - M >= LSN1 - LSN2
与题设条件LSN1 - LSN2 > L矛盾
```

MySQL 5.6/5.7是：

*   若LSN1 - LSN2 > 0，Page2比Page1先插入到Flush-List中

MySQL 8.0是：

*   若LSN1 - LSN2 > L，Page2比Page1先插入到Flush-List中

运行中的recent\_closed和Flush-List类似下图：橙色方框内的Page按照oldest\_modification无序；橙色方框内的Page按照oldest\_modification有序（即集合{74，76，77，75}任一元素均大于集合{72，73，71}）

  

          ![](assets/1601638654-1fc728d7c8c5c7a3dac1bb8a158d1268.png)

  

下图的每个紫色方块为一个脏页，纵坐标为脏页的oldest\_modifaction，横坐标为脏页加入到Flush-List的时间

*   OLD\_DESIGN：脏页的oldest\_modifaction越小，插入到Flush-List的时间越早
*   NEW\_DESIGN：在同一个“L区间”，Page无序；在不同的“L区间”，Page有序

![](assets/1601638654-888e4df92f2f0e43fd0bb09d19b896b8.png)

注：Flush-List采用头插法，越早插入的页越靠近链表尾部

【Flush-List的顺序约束】是InnoDB Checkpoint的重要前提，而【Flush-List的顺序约束】不再保证，那么Checkpoint如何设计？

### MySQL 8.0的Checkpoint

MySQL 8.0由log\_checkpointer线程负责定期的生成checkpoint\_lsn

#### Checkpoint 1

1\. Log Buffer中Redo日志（修改的Page）已加入到Flush-List的“Low-Water Mark”，****记为C1****

****C1 = recent\_closed.M****

【例4】LSN=6、7、9、10、12的Redo日志修改的Page已加入到Flush-List中，“Low-Water Mark”就是7（因为日志LSN=8产生的Page尚未加入Flush-List）

## ![](assets/1601638654-71189348fa946546f13b9d6ba7c9c5f2.png)

#### Checkpoint 2

Flush-List中的**尾部第一个、不属于临时表空间**的Page记为P：

*   **记为C2** \= P.oldest\_modification - L

记P'是LSN=P.oldest\_modification\_lsn - L的Redo修改的脏页

**_（脏页）P'已经被持久化_**

【证明】根据【Flush-List的顺序约束-8.0】，一定早于P加入到Flush-List中：要么P'已被移除Flush-List（刷写入磁盘），要么P'在P的前面（靠近尾部）

*   要么P'在P的前面（靠近尾部）与P是Flush-List尾部第一个Page矛盾

#### 计算最终的checkpoint\_lsn

C1：若Redo日志的LSN<C1，那么该Redo日志产生的脏页已经插入到FLush-List中

C2：若Redo日志的LSN<C2，那么该Redo日志产生的脏页已经刷写到磁盘

![](assets/1601638654-d7f0c4d7834d797075fe6ae7d6029d39.png)

  

**情况一**：C2 < 0

Flush-List刚被清空，或者数据库刚启动不久

**情况二**：0< C2 < last\_checkpoint\_lsn

数据库运行时，但Flush-List长度“突然”变短

【例5】假设flushed\_lsn从始至终都是10，Time=1之前没有做过Checkpoint（last\_checkpoint\_lsn = 0）

```plain
Time=1时：
C2 = 15-10 = 5
lwn_lsn1 = 5, lwn_lsn2 = 5
checkpoint_lsn = 5
 
Time=2时：
last_checkpoint_lsn = 5, C2=11-10=1
C2 < last_checkpoint_lsn
```

  
![](assets/1601638654-7cda49e316499a7fd656211e8544d704.png)

**情况三：**C2 > last\_checkpoint\_lsn

一般的，数据库运行时

```plain
checkpoint_lsn = min(flushed_lsn, M, max(last_checkpoint_lsn, C2))
```

【注意】我们期望找到目前最大的LSN，记为L'，使得：

*   若Redo日志的LSN<L'，那么该Redo日志产生的脏页已经刷写到磁盘

但通过Flush-List，我们只能保证C2“之前”的Redo满足此要求，C2“之后”的Redo可能满足、可能不满足

因为C2的存在，MySQL 8.0的checkpoint\_lsn相对于MySQL 5.6/5.7“不那么精确”

```plain
C2：log.available_for_checkpoint_lsn
 
Up to this lsn all dirty pages have been flushed to disk. However, this value
is not guaranteed to be the maximum such value. As insertion order to flush
lists is relaxed, the buf_pool_get_oldest_modification_approx() returns
modification time of some page that was inserted the earliest, it doesn't
have to be the oldest modification though. However, the maximum difference
between the first page in flush list, and one with the oldest modification
lsn is limited by the number of entries in the log recent closed buffer.
```

#### Checkpoint带来的问题

```plain
【注意】因为LSN是“离散的”，比如：
MTR1产生日志记录R1：LSN=1，长度10
那么，MTR2产生的日志记录R2：LSN=11
 
以（1，11）区间内的值作为LSN的日志是不存在的
```

选取C2 = Page.oldest\_modification\_lsn - L，**_可能导致checkpoint\_lsn并未指向一个日志记录的开始__，而是中间_**。比如继续上面的例子：

*   MTR1产生日志记录R1：LSN=1，长度10
*   那么，MTR2产生的日志记录R2：LSN=11
*   L = 5，MTR2在Flush-List的头部：checkpoint\_lsn可以是11（R2的LSN） - L = 6；指向了R1的中间

这需要我们继续修改Crash Recovery的设计

### MySQL 8.0的Crash Recovery

当checkpoint\_lsn指向日志记录的中间时：

*   通过checkpoint\_lsn找到Block的**LOG\_BLOCK\_FIRST\_REC\_GROUP**（Log Block中第一条Redo日志的偏移）
    
    ```plain
    static void recv_recovery_begin(log_t &log, lsn_t *contiguous_lsn) {
        // contiguous_lsn即是checkpoint_lsn，首先按照OS_FILE_LOG_BLOCK_SIZE（512）对齐
        *contiguous_lsn =
            ut_uint64_align_down(*contiguous_lsn, OS_FILE_LOG_BLOCK_SIZE);
      
        lsn_t start_lsn = *contiguous_lsn;
      
        recv_read_log_seg(start_lsn)
          |- log_files_real_offset_for_lsn(start_lsn)
    }
    ```
    
      
    ![](assets/1601638654-1f67d280e9812cea39162918fbf052de.png)
    

  

*   从该Log Block的第一个日志记录（**LOG\_BLOCK\_FIRST\_REC\_GROUP**）依次向后扫描/解析，直至日志记录的LSN>=checkpoint\_lsn
*   从该LSN开始进行崩溃恢复

## 遗留问题

1\. flush\_order mutex的粒度，只是保护链表指针的修改？  
2\. flush list做成有序链表的代价？用红黑树？  
3\. C2的实现，取Flush-List第一个Page，还是最后一个？

## 参考

1.  [MySQL · 特性分析 · 8.0 对WAL的设计修改](http://mysql.taobao.org/monthly/2018/06/01/)
2.  [MySQL 8.0: New Lock free, scalable WAL design](https://mysqlserverteam.com/mysql-8-0-new-lock-free-scalable-wal-design/)
3.  [Sunny+Bains%40InnoDB.pdf](#)

  

