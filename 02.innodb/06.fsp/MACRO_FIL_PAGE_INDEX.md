#1.FIL_PAGE_INDEX

```cpp

Index Page
InnoDB中存在数量最多的一类Page就是Index Page（FIL_PAGE_INDEX），在Basic Page Header（下图中的FIL Header）之后便是INDEX Header、FSEG Header



FSEG Header
前面提到过每个B+Tree有两个Segment：Internal Node Segment / Leaf Node Segment，每个Segment在INODE Page中存在一个记录项，在B+Tree根节点中记录了（该Segment所占用的）INODE Page的位置及INODE Entry偏移，即FSEG Header（PAGE_BTR_SEG_LEAF / PAGE_BTR_SEG_TOP）。

FSEG Header 的指向该Segment申请的INODE Entry，格式为：

FSEG_HDR_SPACE：INODE Entry所在的Space id

FSEG_HDR_PAGE_NO：INODE Entry所在的Page no

FSEG_HDR_OFFSET：INODE Entry页内偏移量

注：对于Index Page，FSEG Header 仅在根节点生效

- InnoDB重启后，如何找到B+ Tree的根节点？
当需要打开一张表时，需要从数据字典表中加载此表的元数据信息（e.g 列的数量及类型）到 dict_table_t* 内存结构中
其中SYS_INDEXES系统表中记录了表，索引，及索引根节点page no（DICT_FLD__SYS_INDEXES__PAGE_NO）
System Records
即是 Page 上的极大值与极小值记录（infimum/supremum）

User Records
以及 Page Directory（加速页内 record 的查找），请参考 InnoDB（九）：Index Structure & Ops，这里不再展开说明

Layout Overview
这是 Layout 的逻辑视图（注：INODE 节点可以视为 Segment Descriptor Page）

```

#2.内核月报索引页

## 索引页

ibd文件中真正构建起用户数据的结构是BTREE，在你创建一个表时，已经基于显式或隐式定义的主键构建了一个btree，其叶子节点上记录了行的全部列数据（加上事务id列及回滚段指针列）；如果你在表上创建了二级索引，其叶子节点存储了键值加上聚集索引键值。本小节我们探讨下组成索引的物理存储页结构，这里默认讨论的是非压缩页，我们在下一小节介绍压缩页的内容。

每个btree使用两个Segment来管理数据页，一个管理叶子节点，一个管理非叶子节点，每个segment在inode page中存在一个记录项，在btree的root page中记录了两个segment信息。

当我们需要打开一张表时，需要从ibdata的数据词典表中load元数据信息，其中SYS\_INDEXES系统表中记录了表，索引，及索引根页对应的page no（`DICT_FLD__SYS_INDEXES__PAGE_NO`），进而找到btree根page，就可以对整个用户数据btree进行操作。

索引最基本的页类型为`FIL_PAGE_INDEX`。可以划分为下面几个部分。

**Page Header** 首先不管任何类型的数据页都有38个字节来描述头信息（`FIL_PAGE_DATA`, or `PAGE_HEADER`），包含如下信息：

| Macro | bytes | Desc |
| --- | --- | --- |
| FIL\_PAGE\_SPACE\_OR\_CHKSUM | 4 | 在MySQL4.0之前存储space id，之后的版本用于存储checksum |
| FIL\_PAGE\_OFFSET | 4 | 当前页的page no |
| FIL\_PAGE\_PREV | 4 | 通常用于维护btree同一level的双向链表，指向链表的前一个page，没有的话则值为FIL\_NULL |
| FIL\_PAGE\_NEXT | 4 | 和FIL\_PAGE\_PREV类似，记录链表的下一个Page的Page No |
| FIL\_PAGE\_LSN | 8 | 最近一次修改该page的LSN |
| FIL\_PAGE\_TYPE | 2 | Page类型 |
| FIL\_PAGE\_FILE\_FLUSH\_LSN | 8 | 只用于系统表空间的第一个Page，记录在正常shutdown时安全checkpoint到的点，对于用户表空间，这个字段通常是空闲的，但在5.7里，FIL\_PAGE\_COMPRESSED类型的数据页则另有用途。下一小节单独介绍 |
| FIL\_PAGE\_SPACE\_ID | 4 | 存储page所在的space id |

**Index Header** 紧随`FIL_PAGE_DATA`之后的是索引信息，这部分信息是索引页独有的。

| Macro | bytes | Desc |
| --- | --- | --- |
| PAGE\_N\_DIR\_SLOTS | 2 | Page directory中的slot个数 （见下文关于Page directory的描述） |
| PAGE\_HEAP\_TOP | 2 | 指向当前Page内已使用的空间的末尾便宜位置，即free space的开始位置 |
| PAGE\_N\_HEAP | 2 | Page内所有记录个数，包含用户记录，系统记录以及标记删除的记录，同时当第一个bit设置为1时，表示这个page内是以Compact格式存储的 |
| PAGE\_FREE | 2 | 指向标记删除的记录链表的第一个记录 |
| PAGE\_GARBAGE | 2 | 被删除的记录链表上占用的总的字节数，属于可回收的垃圾碎片空间 |
| PAGE\_LAST\_INSERT | 2 | 指向最近一次插入的记录偏移量，主要用于优化顺序插入操作 |
| PAGE\_DIRECTION | 2 | 用于指示当前记录的插入顺序以及是否正在进行顺序插入，每次插入时，PAGE\_LAST\_INSERT会和当前记录进行比较，以确认插入方向，据此进行插入优化 |
| PAGE\_N\_DIRECTION | 2 | 当前以相同方向的顺序插入记录个数 |
| PAGE\_N\_RECS | 2 | Page上有效的未被标记删除的用户记录个数 |
| PAGE\_MAX\_TRX\_ID | 8 | 最近一次修改该page记录的事务ID，主要用于辅助判断二级索引记录的可见性。 |
| PAGE\_LEVEL | 2 | 该Page所在的btree level，根节点的level最大，叶子节点的level为0 |
| PAGE\_INDEX\_ID | 8 | 该Page归属的索引ID |

**Segment Info** 随后20个字节描述段信息，仅在Btree的root Page中被设置，其他Page都是未使用的。

| Macro | bytes | Desc |
| --- | --- | --- |
| PAGE\_BTR\_SEG\_LEAF | 10(FSEG\_HEADER\_SIZE) | leaf segment在inode page中的位置 |
| PAGE\_BTR\_SEG\_TOP | 10(FSEG\_HEADER\_SIZE) | non-leaf segment在inode page中的位置 |

10个字节的inode信息包括：

| Macro | bytes | Desc |
| --- | --- | --- |
| FSEG\_HDR\_SPACE | 4 | 描述该segment的inode page所在的space id （目前的实现来看，感觉有点多余…） |
| FSEG\_HDR\_PAGE\_NO | 4 | 描述该segment的inode page的page no |
| FSEG\_HDR\_OFFSET | 2 | inode page内的页内偏移量 |

通过上述信息，我们可以找到对应segment在inode page中的描述项，进而可以操作整个segment。

**系统记录** 之后是两个系统记录，分别用于描述该page上的极小值和极大值，这里存在两种存储方式，分别对应旧的InnoDB文件系统，及新的文件系统（compact page）

| Macro | bytes | Desc |
| --- | --- | --- |
| REC\_N\_OLD\_EXTRA\_BYTES + 1 | 7 | 固定值，见infimum\_supremum\_redundant的注释 |
| PAGE\_OLD\_INFIMUM | 8 | “infimum\\0” |
| REC\_N\_OLD\_EXTRA\_BYTES + 1 | 7 | 固定值，见infimum\_supremum\_redundant的注释 |
| PAGE\_OLD\_SUPREMUM | 9 | “supremum\\0” |

Compact的系统记录存储方式为：

| Macro | bytes | Desc |
| --- | --- | --- |
| REC\_N\_NEW\_EXTRA\_BYTES | 5 | 固定值，见infimum\_supremum\_compact的注释 |
| PAGE\_NEW\_INFIMUM | 8 | “infimum\\0” |
| REC\_N\_NEW\_EXTRA\_BYTES | 5 | 固定值，见infimum\_supremum\_compact的注释 |
| PAGE\_NEW\_SUPREMUM | 8 | “supremum”，这里不带字符0 |

两种格式的主要差异在于不同行存储模式下，单个记录的描述信息不同。在实际创建page时，系统记录的值已经初始化好了，对于老的格式(REDUNDANT)，对应代码里的`infimum_supremum_redundant`，对于新的格式(compact)，对应`infimum_supremum_compact`。infimum记录的固定heap no为0，supremum记录的固定Heap no 为1。page上最小的用户记录前节点总是指向infimum，page上最大的记录后节点总是指向supremum记录。

具体参考索引页创建函数：`page_create_low`

**用户记录** 在系统记录之后就是真正的用户记录了，heap no 从2（`PAGE_HEAP_NO_USER_LOW`）开始算起。注意Heap no仅代表物理存储顺序，不代表键值顺序。

根据不同的类型，用户记录可以是非叶子节点的Node指针信息，也可以是只包含有效数据的叶子节点记录。而不同的行格式存储的行记录也不同，例如在早期版本中使用的redundant格式会被现在的compact格式使用更多的字节数来描述记录，例如描述记录的一些列信息，在使用compact格式时，可以改为直接从数据词典获取。因为redundant属于渐渐被抛弃的格式，本文的讨论中我们默认使用Compact格式。在文件rem/rem0rec.cc的头部注释描述了记录的物理结构。

每个记录都存在rec header，描述如下（参阅文件include/rem0rec.ic）

| bytes | Desc |
| --- | --- |
| 变长列长度数组 | 如果列的最大长度为255字节，使用1byte；否则，0xxxxxxx (one byte, length=0..127), or 1exxxxxxxxxxxxxx (two bytes, length=128..16383, extern storage flag) |
| SQL-NULL flag | 标示值为NULL的列的bitmap，每个位标示一个列，bitmap的长度取决于索引上可为NULL的列的个数(dict\_index\_t::n\_nullable)，这两个数组的解析可以参阅函数`rec_init_offsets` |
| 下面5个字节（REC\_N\_NEW\_EXTRA\_BYTES）描述记录的额外信息 | …. |
| REC\_NEW\_INFO\_BITS (4 bits) | 目前只使用了两个bit，一个用于表示该记录是否被标记删除(`REC_INFO_DELETED_FLAG`)，另一个bit(REC\_INFO\_MIN\_REC\_FLAG)如果被设置，表示这个记录是当前level最左边的page的第一个用户记录 |
| REC\_NEW\_N\_OWNED (4 bits) | 当该值为非0时，表示当前记录占用page directory里一个slot，并和前一个slot之间存在这么多个记录 |
| REC\_NEW\_HEAP\_NO (13 bits) | 该记录的heap no |
| REC\_NEW\_STATUS (3 bits) | 记录的类型，包括四种：`REC_STATUS_ORDINARY`(叶子节点记录)， `REC_STATUS_NODE_PTR`（非叶子节点记录），`REC_STATUS_INFIMUM`(infimum系统记录)以及`REC_STATUS_SUPREMUM`(supremum系统记录) |
| REC\_NEXT (2bytes) | 指向按照键值排序的page内下一条记录数据起点，这里存储的是和当前记录的相对位置偏移量（函数`rec_set_next_offs_new`） |

在记录头信息之后的数据视具体情况有所不同：

*   对于聚集索引记录，数据包含了事务id，回滚段指针；
*   对于二级索引记录，数据包含了二级索引键值以及聚集索引键值。如果二级索引键和聚集索引有重合，则只保留一份重合的，例如pk (col1, col2)，sec key(col2, col3)，在二级索引记录中就只包含(col2, col3, col1);
*   对于非叶子节点页的记录，聚集索引上包含了其子节点的最小记录键值及对应的page no；二级索引上有所不同，除了二级索引键值外，还包含了聚集索引键值，再加上page no三部分构成。

**Free space** 这里指的是一块完整的未被使用的空间，范围在页内最后一个用户记录和Page directory之间。通常如果空间足够时，直接从这里分配记录空间。当判定空闲空间不足时，会做一次Page内的重整理，以对碎片空间进行合并。

**Page directory** 为了加快页内的数据查找，会按照记录的顺序，每隔4~8个数量（`PAGE_DIR_SLOT_MIN_N_OWNED` ~ `PAGE_DIR_SLOT_MAX_N_OWNED`）的用户记录，就分配一个slot （每个slot占用2个字节，`PAGE_DIR_SLOT_SIZE`），存储记录的页内偏移量，可以理解为在页内构建的一个很小的索引(sparse index)来辅助二分查找。

Page Directory的slot分配是从Page末尾（倒数第八个字节开始）开始逆序分配的。在查询记录时。先根据page directory 确定记录所在的范围，然后在据此进行线性查询。

增加slot的函数参阅 `page_dir_add_slot`

页内记录二分查找的函数参阅 `page_cur_search_with_match_bytes`

**FIL Trailer** 在每个文件页的末尾保留了8个字节（`FIL_PAGE_DATA_END` or `FIL_PAGE_END_LSN_OLD_CHKSUM`），其中4个字节用于存储page checksum，这个值需要和page头部记录的checksum相匹配，否则认为page损坏(`buf_page_is_corrupted`)


