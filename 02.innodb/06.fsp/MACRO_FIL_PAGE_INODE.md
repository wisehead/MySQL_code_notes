#1.MACRO FIL_PAGE_INODE

```cpp
/* @defgroup File Segment Inode Constants (moved from fsp0fsp.c) @{ */

/*          FILE SEGMENT INODE
            ==================

Segment inode which is created for each segment in a tablespace. NOTE: in
purge we assume that a segment having only one currently used page can be
freed in a few steps, so that the freeing cannot fill the file buffer with
bufferfixed file pages. */

typedef byte    fseg_inode_t;

#define FSEG_INODE_PAGE_NODE    FSEG_PAGE_DATA
                    /* the list node for linking
                    segment inode pages */

#define FSEG_ARR_OFFSET     (FSEG_PAGE_DATA + FLST_NODE_SIZE)
/*-------------------------------------*/
#define FSEG_ID         0   /* 8 bytes of segment id: if this is 0,
                    it means that the header is unused */
#define FSEG_NOT_FULL_N_USED    8
                    /* number of used segment pages in
                    the FSEG_NOT_FULL list */
#define FSEG_FREE       12
                    /* list of free extents of this
                    segment */
#define FSEG_NOT_FULL       (12 + FLST_BASE_NODE_SIZE)
                    /* list of partially free extents */
#define FSEG_FULL       (12 + 2 * FLST_BASE_NODE_SIZE)
                    /* list of full extents */
#define FSEG_MAGIC_N        (12 + 3 * FLST_BASE_NODE_SIZE)
                    /* magic number used in debugging */
#define FSEG_FRAG_ARR       (16 + 3 * FLST_BASE_NODE_SIZE)
                    /* array of individual pages
                    belonging to this segment in fsp
                    fragment extent lists */
#define FSEG_FRAG_ARR_N_SLOTS   (FSP_EXTENT_SIZE / 2)
                    /* number of slots in the array for
                    the fragment pages */
#define FSEG_FRAG_SLOT_SIZE 4   /* a fragment page slot contains its
                    page number within space, FIL_NULL
                    means that the slot is not in use */
/*-------------------------------------*/


Segment Descripter Page（INODE Page）
表空间的第三个Page 叫做 “INODE Page”（其实叫做 Segment Descripter Page 更合适，但 InnoDB 重载了名词“INODE Page”）

        



INODE Page 上存在 84 个 INODE Entry。Segment 与 INODE Entry 是一一对应的，INODE Entry可以作为 Segment Descripter，保存该 Segment 的元数据

每个INODE Entry包含：

FSEG_ID：该Inode归属的 Segment ID，若值为0表示该 slot 未被使用
FSEG_NOT_FULL_N_USED：FSEG_NOT_FULL链表上被使用的Page数量
FSEG_MAGIC_N：Magic Number
【四个 XDES Entry 链表】（链表上的对象是 XDES Entry，即 Extent）

FSEG_FREE：完全没有被使用并分配给该 Segment 的 Extent链表
FSEG_NOT_FULL：FSEG_FREE 中的 Extent 被使用后，移动到 FSEG_NOT_FULL 链表；FSEG_NOT_FULL 链表中的 Extent 用完后，移动到 FSEG_FULL 链表。反之也成立
FSEG_FULL：分配给当前 Segment，且Page完全使用完的Extent链表
FSEG_FRAG_ARR：属于该 Segment 的独立的 Page 数组（数组每个元素是 page no）。总是先从全局分配独立的 Page（FSP_FREE_FRAG 链表），当数组被填满时（32 Page），每次分配时都分配一个完整的 Extent，并在 XDES PAGE 中将其 Segment ID 设置为当前值
建立新的 Segment 有几个典型场景：

用户表空间对于每个索引（聚簇索引或二级索引）需要申请两个 Segment：Internal Node Seg / Leaf Node Seg（所以在使用 innodb_file_per_table 时，通常 INODE Page 都很空，除非该表上有超过42个索引。当超过42个索引后，就需要分配新的 INODE Page（fsp_alloc_seg_inode_page）。分配的方式同【从表空间申请单独的Page / Extent】小节，新的 INODE Page 位置并不固定）
Undo tablespace 需要建立 128 个 rollback seg（MySQL 5.7/8/0）。
对于建立的每个 Segment：

需要现在 INODE Page 申请一个 Entry。其次 Tablespace 中为其申请第一个 Page 作为 Segment Header Page
在 Segment Header Page 上存有 FSEG header（10个字节），偏移处由调用者指定（根据 Segment 的用处而不同，比如 Rollback seg 指定的偏移是 TRX_RSEG_FSEG_HEADER）
 Segment Header Page 上的内容也有调用者填充（e.g Rollback seg 保存 TRX_RSEG_HISTORY ,TRX_RSEG_UNDO_SLOTS 等等）
FSEG header 主要存放指针指向 Segment 的 INODE Entry

#define FSEG_HDR_SPACE 0   /*!< space id of the inode */
#define FSEG_HDR_PAGE_NO 4 /*!< page number of the inode */
#define FSEG_HDR_OFFSET 8  /*!< byte offset of the inode */
Segment Header Page 由调用方妥善保存，比如存放在 trx_rsegf_t 中（rollback seg），存放在系统表中（B-tree index 根节点）


```

#2.Alibaba

### INODE PAGE

数据文件的第3个page的类型为`FIL_PAGE_INODE`，用于管理数据文件中的segement，每个索引占用2个segment，分别用于管理叶子节点和非叶子节点。每个inode页可以存储`FSP_SEG_INODES_PER_PAGE`（默认为85）个记录。

| Macro | bits | Desc |
| --- | --- | --- |
| FSEG\_INODE\_PAGE\_NODE | 12 | INODE页的链表节点，记录前后Inode Page的位置，BaseNode记录在头Page的FSP\_SEG\_INODES\_FULL或者FSP\_SEG\_INODES\_FREE字段。 |
| Inode Entry 0 | 192 | Inode记录 |
| Inode Entry 1 |   |   |
| …… |   |   |
| Inode Entry 84 |   |   |

每个Inode Entry的结构如下表所示：

| Macro | bits | Desc |
| --- | --- | --- |
| FSEG\_ID | 8 | 该Inode归属的Segment ID，若值为0表示该slot未被使用 |
| FSEG\_NOT\_FULL\_N\_USED | 8 | FSEG\_NOT\_FULL链表上被使用的Page数量 |
| FSEG\_FREE | 16 | 完全没有被使用并分配给该Segment的Extent链表 |
| FSEG\_NOT\_FULL | 16 | 至少有一个page分配给当前Segment的Extent链表，全部用完时，转移到FSEG\_FULL上，全部释放时，则归还给当前表空间FSP\_FREE链表 |
| FSEG\_FULL | 16 | 分配给当前segment且Page完全使用完的Extent链表 |
| FSEG\_MAGIC\_N | 4 | Magic Number |
| FSEG\_FRAG\_ARR 0 | 4 | 属于该Segment的独立Page。总是先从全局分配独立的Page，当填满32个数组项时，就在每次分配时都分配一个完整的Extent，并在XDES PAGE中将其Segment ID设置为当前值 |
| …… | …… |   |
| FSEG\_FRAG\_ARR 31 | 4 | 总共存储32个记录项 |

