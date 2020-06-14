#1.MACRO FIL_PAGE_TYPE_XDES


```cpp

/* @defgroup Extent Descriptor Constants (moved from fsp0fsp.c) @{ */

/*          EXTENT DESCRIPTOR
            =================

File extent descriptor data structure: contains bits to tell which pages in
the extent are free and which contain old tuple version to clean. */

/*-------------------------------------*/
#define XDES_ID         0   /* The identifier of the segment
                    to which this extent belongs */
#define XDES_FLST_NODE      8   /* The list node data structure
                    for the descriptors */
#define XDES_STATE      (FLST_NODE_SIZE + 8)
                    /* contains state information
                    of the extent */
#define XDES_BITMAP     (FLST_NODE_SIZE + 12)
                    /* Descriptor bitmap of the pages
                    in the extent */
/*-------------------------------------*/


Extent Descripter Page（FIL_PAGE_TYPE_XDES）
一个 Extent 由物理上连续的 64 个 Page 构成（1MB），每个 Extent Descripter Page（简写XDES）用来描述包含其在内的256个 Extent（一共 256*64 个页，每个 Extent  64 个页 1MB）

XDES Layout 与 Tablespace Descripter Page 完全相同，只是 Part I 为空

XDES 由256个 Entry 组成（XDES_ARR_OFFSET），每个 Entry 包含128 bit（16B）的XDES_BITMAP域，2 bits 描述 Extent 中的一个 Page：

一个bit（XDES_FREE_BIT）表示该页是否闲置
一个bit 暂未使用
XDES Entry 与 Extent 是一一对应

（当 innodb_page_size = 16KB 时）因为一个 XDES 只能用来描述 256 个 Extent，所以每 256 个 Extent 就需要创建一个 XDES

```


#2.Ali 

除了上述描述信息外，其他部分的数据结构和XDES PAGE（`FIL_PAGE_TYPE_XDES`）都是相同的，使用连续数组的方式，每个XDES PAGE最多存储256个XDES Entry，每个Entry占用40个字节，描述64个Page（即一个Extent）。格式如下：

| Macro | bytes | Desc |
| --- | --- | --- |
| XDES\_ID | 8 | 如果该Extent归属某个segment的话，则记录其ID |
| XDES\_FLST\_NODE | 12(FLST\_NODE\_SIZE) | 维持Extent链表的双向指针节点 |
| XDES\_STATE | 4 | 该Extent的状态信息，包括：XDES\_FREE，XDES\_FREE\_FRAG，XDES\_FULL\_FRAG，XDES\_FSEG，详解见下文 |
| XDES\_BITMAP | 16 | 总共16\*8= 128个bit，用2个bit表示Extent中的一个page，一个bit表示该page是否是空闲的(XDES\_FREE\_BIT)，另一个保留位，尚未使用（XDES\_CLEAN\_BIT） |

`XDES_STATE`表示该Extent的四种不同状态：

| Macro | Desc |
| --- | --- |
| XDES\_FREE(1) | 存在于FREE链表上 |
| XDES\_FREE\_FRAG(2) | 存在于FREE\_FRAG链表上 |
| XDES\_FULL\_FRAG(3) | 存在于FULL\_FRAG链表上 |
| XDES\_FSEG(4) | 该Extent归属于ID为XDES\_ID记录的值的SEGMENT。 |

通过`XDES_STATE`信息，我们只需要一个`FLIST_NODE`节点就可以维护每个Extent的信息，是处于全局表空间的链表上，还是某个btree segment的链表上。

