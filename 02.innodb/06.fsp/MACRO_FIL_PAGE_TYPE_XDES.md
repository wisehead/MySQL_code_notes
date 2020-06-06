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


