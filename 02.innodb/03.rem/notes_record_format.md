#1.用户记录格式

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

#2.系统记录格式
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

