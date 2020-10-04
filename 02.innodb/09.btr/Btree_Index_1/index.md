

# [InnoDB（9.1）：B-tree Index]


  

# 记录

InnoDB的数据记录分为物理记录（record）和逻辑记录（tuple），物理记录即是记录在文件中（磁盘）的存储形式。这里只考虑普通的记录，非大记录（_blob_）

## 物理记录（record）

  

  ![](assets/1601783417-d9286ccd96d7e0263aba2e069e9ef5e7.png)

  

即记录在磁盘文件上的格式。如上图

*   column offset list：每个列的偏移列表，包括三个系统列（**DB\_ROW\_ID** / **DB\_TRX\_ID** / **DB\_ROLL\_PTR**）
*   record header：记录头部（6 字节），最后的「next record」指向下一个记录的「original offset」处
*   original offset：该记录实际数据的开始位置

```plain
CREATE TABLE t (
    t1 VARCHAR(10),
    t2 VARCHAR(10),
    t3 CHAR(10),
    t4 VARCHAR(10),
) ENGINE = InnoDB
 
INSERT INTO t VALUES ('a', 'bb', 'bb', 'ccc');
 
// hexdump ...
/* Column offset list，7个列（逆序存放）：
第一列（DB_ROW_ID）：0x00 - 0x06，左闭右开区间（0x06是第二列起始地址）、6个字节
第二列（DB_TRX_ID）：0x06 - 0x0c，6个字节
第三列（DB_ROLL_PTR）：0x0c - 0x13，7个字节
第四列（t1）：0x13 - 0x14，1个字节
第五列（t2）：...
*/
23 20 16 14 13 0c 06
00 00 10 0f 00 ba /* Record Header，6 Bytes */
00 00 00 2b 68 0b /* DB_ROW_ID */
00 00 00 00 06 53 /* DB_TRX_ID */
80 00 00 00 32 01 01 /* DB_ROLL_PTR */
61 /* t1 'a' */
62 62 /* t2 'bb' */
62 62 20 20 20 20 20 20 20 20 20 20 /* t3 'bb'，CHAR类型 */
63 63 63  /* t4 'ccc' */
```

## 逻辑记录（tuple）

                  ![](assets/1601783417-8cddcadb362129957ba27132f8a9eb09.png)

  

逻辑记录即是在内存中的表示（data structure），如上图：

*   n\_fields：列的数量
*   fields：列（dfield\_t）的数组，存储指向每一列真实数据的指针
*   tuple\_list：连接多个 tuple（每个索引都有一个 tuple，比如 INSERT SQL 需要向主键索引和二级索引中都插入时）

```plain
/** Structure for an SQL data field */
struct dfield_t{
    void*  data;      // 真实列数据的指针
    unsigned  ext:1;  // 如果是大记录（blob），则在外部页存储
    unsigned  len:32; // 列数据的长度    
    dtype_t  type;    // 列数据的类型
};
```

# 基于 B-tree 的索引

InnoDB的索引全貌（[B+Tree index structures in InnoDB](https://blog.jcole.us/2013/01/10/btree-index-structures-in-innodb/)）：

![](assets/1601783417-ad28da6c69129a2b2d5c25f72d4aace4.png)

其中：

*   树高度的定义：叶子节点是 0，父节点高度是子节点高度 +1
*   每一个 record 由 key + value 组成：
    *   中间节点的 key：保存的是其**子节点中最小的 key**
    *   中间节点的 value：是一个 pointer（page\_no），指向子节点（可能是中间节点，可能是叶子节点）
    *   叶子节点的 key：能唯一确定该数据行的若干列（对于不同索引不一样，主键列、或唯一键列、或二级索引列+主键列）
    *   叶子节点的 value：其余列
*   同一高度的 page 连接成 **双向链表**，称作 page list
*   同一 page 的 record 连接成 **单向链表**，称作 record list（按 record key 升序连接）。数据页内的 record 逻辑上相邻，物理上不一定相邻
*   Infimum record（下确界）/ supremum record（上确界）：两个系统记录（具有固定页内偏移量），为一个 page 内 record list 的头/尾节点

B-tree 是一种加速查找的数据结构，从主键索引或二级索引里查找一个记录（tuple）需要进行 **B-tree 遍历**。通过 btr\_cur\_search\_to\_nth\_level 这个函数完成

```plain
void btr_cur_search_to_nth_level(
    dict_index_t *index,   /*!< in: index */
    ulint level,           /*!< in: the tree level of search */
    const dtuple_t *tuple, /*!< in: data tuple; NOTE: n_fields_cmp in
                           tuple must be set so that it cannot get
                           compared to the node ptr page number field! */
    page_cur_mode_t search_mode,  /*!< in: PAGE_CUR_L, ...;
                           Inserts should always be made using
                           PAGE_CUR_LE to search the position! */
    ulint latch_mode,      /*!< in: BTR_SEARCH_LEAF, ..., ORed with
                       at most one of BTR_INSERT, BTR_DELETE_MARK,
                       BTR_DELETE, or BTR_ESTIMATE;
                       cursor->left_block is used to store a pointer
                       to the left neighbor page, in the cases
                       BTR_SEARCH_PREV and BTR_MODIFY_PREV;
                       NOTE that if has_search_latch
                       is != 0, we maybe do not have a latch set
                       on the cursor page, we assume
                       the caller uses his search latch
                       to protect the record! */
    btr_cur_t *cursor,     /*!< in/out: tree cursor; the cursor page is
                           s- or x-latched, but see also above! */
    ulint has_search_latch,
    /*!< in: info on the latch mode the
    caller currently has on search system:
    RW_S_LATCH, or 0 */
    const char *file, /*!< in: file name */
    ulint line,       /*!< in: line where called */
    mtr_t *mtr)       /*!< in: mtr */
```

在查找过程中：

1.  **记录定位**：根据 **tuple**（参数中的 tuple）和 **search mode**（参数中的 mode）最终会定位到某个数据页上的某个 record
2.  **并发控制**：根据 **latch mode**（参数中的 latch\_mode）的不同，在遍历过程中采用不同的加锁（latch）策略

## 记录定位

### 二分查找算法与四种 search mode

InnoDB 在数据页内使用的是二分查找。对于 B-tree 数据页上的二分查找有四种 **search mode**，这四种 **search mode** 决定了最后定位哪个记录（具体可见 page\_cur\_search\_with\_match 函数）

*   PAGE\_CUR\_G（>，大于）：SELECT \* WHERE column > 1
    
*   PAGE\_CUR\_GE（>=，大于等于）：UPDATE / DELETE / SELECT \* WHERE column = 1
    
*   PAGE\_CUR\_L（<，小于）：SELECT \* WHERE column < 1
    
*   PAGE\_CUR\_LE（<=，小于等于）：INSERT ...
    
      
    

 ![](assets/1601783417-c54922597d4cdc9eeeef15887f06cc50.jpg) 

  

这里先介绍一个概念：cursor（游标）。最后定位哪个记录，我们就说 cursor 置于哪个记录上，类似于一个 record 指针，更具体的关于 cursor 的内容下文会再介绍。上图1中，SELECT \* WHERE id > 40 使用 PAGE\_CUR\_G 定位到（将 cursor 置于）第一个大于 40 的 record 上（记录 50），与该 SQL 的语义符合。其他 search mode 同理。

### 中间节点的 search mode

但对于中间节点只使用两种模式，PAGE\_CUR\_L / PAGE\_CUR\_LE，转换关系在函数 btr\_cur\_search\_to\_nth\_level 之中

```plain
// page_mode即为中间节点使用的搜索模式
switch (mode) {
  case PAGE_CUR_GE:
      page_mode = PAGE_CUR_L;
      break;
  case PAGE_CUR_G:
      page_mode = PAGE_CUR_LE;
      break;
  default:
      page_mode = mode;
      break;
}
```

这是为什么？为什么 PAGE\_CUR\_GE 对应于 PAGE\_CUR\_L，而不是 PAGE\_CUR\_LE？

如下图，假设 PAGE\_CUR\_GE 对应于 PAGE\_CUR\_LE，在二级索引中我们执行：

*   Trx1：SELECT >= 50

根据索引页内的二分查找算法，PAGE\_CUR\_LE 的选择路径如图中虚线所示，最终会定位在 Leaf 3 的第一个 50 上，导致在叶子节点既需要向左移动，有需要向右移动，这并不是一个好的做法。而如果使用 PAGE\_CUR\_L 呢？因为使用的模式是 PAGE\_CUR\_L，会导致选择中间节点10。但此种情况下最终会将 cursor 置于 Leaf1 内的 supremum record 中，进而找到 Leaf2。因此使用 PAGE\_CUR\_L 要优于 PAGE\_CUR\_LE

         ![](assets/1601783417-cdeb067bcbf6ca89d50ee3fc3f964569.jpg)

### 中间节点查找溢出

这里还需要注意一个 corner case。首先要注意中间节点记录的 key 保存的是其子节点中最小的 key。那么比如右图 SELECT >=5，难道在 root page 二分查找法会选择 infimum record？在每一层的最左节点都会被置一个标记 REC\_INFO\_MIN\_REC\_FLAG（record info bits），可以发现该记录是中间节点的最小记录（图中的 10），便不会选择  infimum record 了

## 基于锁（latch）的并发控制

我们基于MySQL 8.0.17。在B+ tree上共有三种操作：

*   读（**BTR\_SEARCH\_LEAF** / **BTR\_SEARCH\_LEAF**）：分为点查询和范围查询
*   乐观写（**BTR\_MODIFY\_LEAF**）：仅影响到一个索引页的增删改
*   悲观写（**BTR\_MODIFY\_TREE**）：影响到超过一个索引页的增删改（e.g. DELETE SQL导致了页合并）

并发控制使用两种 latch：index latch / page latch

我们再插入一些说明：数据库里的latch / lock的不同，latch与lock都可以用来完成2PL（2 Phase Locking），使用 latch 的是 MTR（物理事务），使用lock的是用户事务（逻辑事务）。因此这里 latch 和 MTR 都是物理意义的，lock 与 用户事务（Transaction）都是逻辑意义上的

### 九种 latch mode

search mode 决定在 B-tree 查找时返回什么记录，latch mode 决定在 B-tree 查找时如何对路径加锁。InnoDB 目前定义了九种 latch mode，每一种都有不同在不同场景下使用：

```plain
/** Latching modes for btr_cur_search_to_nth_level(). */
enum btr_latch_mode : size_t {  
  /** Search a record on a leaf page and S-latch it. */
  BTR_SEARCH_LEAF,
  /** (Prepare to) modify a record on a leaf page and X-latch it. */
  BTR_MODIFY_LEAF,
  /** Obtain no latches. */
  BTR_NO_LATCHES,
  /** Start modifying the entire B-tree. */
  BTR_MODIFY_TREE = 33,
  /** Continue modifying the entire B-tree. */
  BTR_CONT_MODIFY_TREE = 34,
  /** Search the previous record. */
  BTR_SEARCH_PREV = 35,
  /** Modify the previous record. */
  BTR_MODIFY_PREV = 36,
  /** Start searching the entire B-tree. */
  BTR_SEARCH_TREE = 37,
  /** Continue searching the entire B-tree. */
  BTR_CONT_SEARCH_TREE = 38
};
```

### **1. BTR\_SEARCH\_LEAF（点查询****）**

![](assets/1601783417-2066ff69cff837309526b1c21dc23a37.jpg)

  

*   获得索引的 S lock
*   **由上至下**依次获取搜索路径节点的 S lock，直至叶子节点
*   释放索引和中间节点的 S lock，仅保留叶子节点
*   读叶子节点的内容 ......
*   释放叶子节点 S lock

**附：范围查询怎么做？**

我们知道范围查询的第一步是点查询（如SELECT id>40，先定位到记录10，然后沿着叶子节点向右扫描），在叶节点切换时，我们尤其要注意。

正序方向（move\_up = true）因为符合 latch order 很简单：

1.  获得右兄弟 S lock
2.  释放自身的 S lock

逆序方向（move\_up = false）因为不符合 latch order 比较复杂，等介绍完 cursor store / restore 再讲

### 2\. BTR\_MODIFY\_LEAF（乐观写）

这个 latch mode 对应于一次不会引起 SMO 的 IUD

1.  获得索引的S lock
2.  **由上至下**依次获取搜索路径节点的S lock
3.  叶子节点获得**X lock**
4.  释放索引和中间节点的S lock，仅保留叶子节点
5.  修改叶子节点的内容 ......
6.  释放叶子节点**X lock**  
    

![](assets/1601783417-9b01d34c4263ef3c4f21d87ca84fc3ba.jpg)

### 3\. BTR\_MODIFY\_TREE（悲观写）

这个 latch mode 对应于一次会引起 SMO 的 IUD。

下图展示了插入记录 40 引起叶节点分裂的情况

1.  获得索引的 **SX lock**
2.  **由上至下** 依次获取 **可能引起分裂或合并** 的节点（如P1）的 **X lock**
3.  依次获得叶子节点 **左兄弟、自身、右兄弟** 的 **X lock**
4.  修改索引结构和叶子节点的内容 ......
5.  释放所有 **X lock**

  

![](assets/1601783417-c656ef4681418e127fc57754dc19efef.jpg)

#### 右兄弟节点：INSERT 的优化及麻烦

当 INSERT 可能导致索引页（中间节点或叶节点）分裂时，如果 INSERT 的位置在索引页的最后，而且右兄弟指针不为空，试着直接插入到右兄弟（btr\_insert\_into\_right\_sibling）。我们来详细分析这个过程

```plain
|- btr_pcur_open
|- btr_cur_pessimistic_insert
  |- btr_page_split_and_insert
    |- btr_insert_into_right_sibling(
      // Step-1：得到右兄弟的父节点
      // next_father_cursor 指向了父节点对应的 node_ptr。这里会调用 btr_search_to_nth_level，搜索
      // 到 next_block 上一层，latch mode 是 BTR_CONT_MODIFY_TREE。BTR_CONT_MODIFY_TREE 的模式下
      // 不会对 index 及沿途路径加锁，只在返回前对目标索引页加 X latch
      |- btr_page_get_father(cursor->index, next_block, mtr, &next_father_cursor);
   
      // Step-2：在 next_block 寻找放置 tuple 的位置（就是第一个 record）
      |- page_cur_search(next_block, cursor->index, tuple, PAGE_CUR_LE, &next_page_cursor);
 
      // Step-3：把 tuple 插入到 next_page_cursor 指向的位置
      |- page_cur_tuple_insert(next_page_cursor, mtr ...)
 
      // Step-4：修改上级节点的 node ptr
      // 删除父节点中指向该页（next_block）的 node_ptr，当删除 node_ptr 后尝试压缩父节点，然后在父节点中插
      // 入新的 node_ptr。在 btr_cur_pessimistic_delete 如果要删除的是中间节点的第一个 node pointer record
      // 简称 node ptr，区别于叶子节点的 user record，需要处理两种特殊情况：
      // 1）如果该中间节点没有左兄弟，把删除之后的第一个 node pointer record 设置 REC_INFO_MIN_REC_FLAG 标记
      //    表示是这一层的最左 node ptr
      // 2）删除其父节点对应的 node ptr，过程同上：
      //    - btr_page_get_father
      //    - btr_cur_pessimistic_delete 
      //    - btr_cur_compress_if_useful
      //    - btr_insert_on_non_leaf_level
      //   这便可能导致级联效果
      |- btr_cur_pessimistic_delete
      |- btr_cur_compress_if_useful
      |- btr_insert_on_non_leaf_level
```

当然，悲观写有两种操作：INSERT / DELETE，分别可能引起 B-tree 节点的分裂或合并，或者即分裂又合并。这三种情况在代码里对应三种 lock intention：

*   BTR\_INTENTION\_INSERT（只引起节点分裂）
    
*   BTR\_INTENTION\_DELETE（只引起节点合并）
    
*   BTR\_INTENTION\_BOTH（可能都会出现）
    

btr\_cur\_will\_modify\_tree 里有一个规则：

*   【规则1】当 lock\_intention <= BTR\_INTENTION\_BOTH 时，而且 cursor 指向数据页的最后一个 record 且右兄弟节点不为空，则不释放其父节点 latch  
    

我们看一个例子来理解这个规则。事务 T1 的行为是：

1.  B-tree 的查找路径 root→P1→P4→P8
2.  调用 btr\_insert\_into\_right\_sibling，准备插入右兄弟节点P9
3.  修改 P5 的 node ptr record
4.  修改 P2 的 node ptr record  
    
5.  修改 root 的 node ptr record

在第4步后如果有一个事务 T2 试图查找 P9，而且已得到 root latch，则会与事务 T1 形成死锁

  

![](assets/1601783417-b8b52037b8258f543f13585ce23f787c.jpg)

  

当对 P1 使用 btr\_insert\_into\_right\_sibling 时，会因为需要路由的 node ptr record（指向 P4）是 P1 的第一个 record，而不会释放 A 父节点（root）的 latch，因而避免上述的死锁发生

我们提出：【规则1】至少会锁住 btr\_insert\_into\_right\_sibling 涉及到的两兄弟节点的 **最近公共祖先**。证明如下：

假设目标叶子节点是 P1，右兄弟是 P2

1.  P1 P2 共用父节点（下图中图 1），则根据 btr\_cur\_search\_to\_nth\_level 中对 BTR\_MODIFY\_TREE 的加锁规则，会锁住 A
2.  设最近公共祖先是 A。A 的子节点中 P1 和 P2 的祖先是分别是 B 和 C。则对 B 使用 btr\_cur\_will\_modify\_tree 时，因为拿到的 node ptr record 一定是 B 的 last record（下图中图 2和图 3），原因很简单，**P1 如果不是 B 的最右子节点。，则 B 将会有其余的子节点作为 P1 的右兄弟，而 P1 的右兄弟是 P2，则 P2 将会是（B）的子节点**，等价于第一种情况

  

![](assets/1601783417-81e5759fb8dee9a140b15c6c7f3f4a31.jpg)

  

#### InnoDB 不使用 latch coupling 的原因

我们再解释 InnoDB 不使用经典的 latch coupling 的原因。latch coupling 就是说锁住子节点之后会释放父节点的 latch。而 InnoDB 目前会在 BTR\_SEARCH\_LEAF 时持有一路中间节点的 latch，直至叶子节点才释放。原因是与上述的 btr\_insert\_into\_right\_sibling 避免死锁。还是之前的例子：

事务 T1 B-tree 的查找路径 root→P1→P4→P8，需要路由的 node ptr record（指向 P4）是 P1 的第一个 record，所以会把 root / P1 / P4 / P8 都锁住。然后调用 btr\_insert\_into\_right\_sibling：

1.  插入右兄弟节点 P9
2.  修改 P5 的 node ptr record
3.  修改 P2 的 node ptr record  
    
4.  修改 root 的 node ptr record  
    

如果使用 latch coupling，比如上述第1步后可能存在事务 T2 只锁住了 P5，准备拿 P9 的锁。和事务 T1 形成死锁

### **4\. BTR\_CONT\_MODIFY\_TREE**

使用于在 B-tree 分裂过程中，搜索得到叶子节点的父节点，或向父节点中插入新的 node ptr 的情况。见 BTR\_MODIFY\_TREE

### **5\. BTR\_SEARCH\_PREV（**向前读）

这种 latch mode 使用于逆向遍历 B-tree 叶子节点时，见下文 例1- B-tree 逆序遍历

当检索到叶子节点时，会 latch 住叶子节点与左兄弟节点。当然加锁顺序是先左兄弟节点而后该节点

  

![](assets/1601783417-764e3de33fa4bcf909c08ff49502d8fb.jpg)

  

但这里要注意一个加锁规则：**左兄弟的父节点（中间节点）同样需要持有 latch，**即上面右图。原因是什么？我们注意到在 B-tree search 到叶子节点时（图中的 P5），如果是 BTR\_SEARCH\_PREV 则需要：

1.  拿到左兄弟的 page no（P4）
2.  获得左兄弟的 latch（P4）
3.  获得自身的 latch（P5）

如果不持有着左兄弟父节点的 latch，那么在第1步和第2步之间如果 P4 发生分裂导致 P5 的左兄弟不再是 P4，则最后函数返回时便不会是 latch 住叶子节点（P5）与左兄弟节点（P4 不再是 P5 的左兄弟）

因此这个规则是为了避免与 BTR\_MODIFY\_TREE（悲观插入 / 删除）产生 race condition。

### **6.** BTR\_MODIFY\_PREV

与 BTR\_SEARCH\_PREV 的区别在于对叶子节点加锁是 x latch。只有在向 Change Buffer 里插入时会使用这个 latch mode

**TOOD** 原因

### 7\. BTR\_SEARCH\_TREE

### 8\. BTR\_CONT\_SEARCH\_TREE

### 9\. BTR\_NO\_LATCHS

## 持久化游标（persistent cursor）



# 参考

*   [B+Tree index structures in InnoDB](https://blog.jcole.us/2013/01/10/btree-index-structures-in-innodb/)
*   [关于innodb中查询的定位方法](https://www.jianshu.com/p/0cdd573a8232)
*   [innodb对B树游标的定位过程以及对“小于(等于)B树最小记录”的特殊处理](http://wqtn22.iteye.com/blog/1820436)
*   [MySQL：一个简单insert语句的大概流程](https://www.jianshu.com/p/5248ca67eac2)
*   [\[MySQL 源码\] Innodb Pessimistic Insert流程](https://yq.aliyun.com/articles/40991)
*   [从MySQL Bug#67718浅谈B+树索引的分裂优化](http://hedengcheng.com/?p=525)
*   [WL#6326: InnoDB: fix index->lock contention](https://dev.mysql.com/worklog/task/?id=6326)
*   [MySQL · 引擎特性 · B+树并发控制机制的前世今生](http://mysql.taobao.org/monthly/2018/09/01/)
*   [MySQL · 引擎特性 · InnoDB index lock前世今生](http://mysql.taobao.org/monthly/2015/07/05/)
*   [从MySQL Bug#67718浅谈B+树索引的分裂优化](http://hedengcheng.com/?p=525)
*   [B-Tree Visualizationwww.](https://www.cs.usfca.edu/~galles/visualization/BPlusTree.html)
*   [InnoDB btree latch 优化历程](https://zhuanlan.zhihu.com/p/151397269)

  

 

