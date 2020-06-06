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