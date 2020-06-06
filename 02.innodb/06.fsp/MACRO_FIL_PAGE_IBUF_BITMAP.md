#1.MACRO FIL_PAGE_IBUF_BITMAP

```cpp
/** @name Offsets to the per-page bits in the insert buffer bitmap */
/* @{ */
#define IBUF_BITMAP_FREE    0   /*!< Bits indicating the
                    amount of free space */
#define IBUF_BITMAP_BUFFERED    2   /*!< TRUE if there are buffered
                    changes for the page */
#define IBUF_BITMAP_IBUF    3   /*!< TRUE if page is a part of
                    the ibuf tree, excluding the
                    root page, or is in the free
                    list of the ibuf */
/* @} */


iBuf Bitmap Page（FIL_PAGE_IBUF_BITMAP）
表空间的第二个 Page 类型为 FIL_PAGE_IBUF_BITMAP，用于描述随后的 256 个 Extent 内数据页中与 iBuf 有关的信息（每个 Page 4 bits）

IBUF_BITMAP_FREE（2 bits）：使用2个bit来描述页的空闲空间范围：0（0B）、1（512B）、2（1024B）、3（2048B）
IBUF_BITMAP_BUFFERED（1 bit）：iBuf 中是否缓存着这个页的操作
IBUF_BITMAP_IBUF（1 bit）：该页是否是 iBuf B-tree的节点
由于iBuf Bitmap Page 的空间有限，同样也会在每个 XDES 之后创建一个iBuf Bitmap Page，用于追踪其后 256 个 Extent 的情况

关于iBuf（Change Buffer）细节请参考InnoDB（八）：Change Buffer，这里不再展开讨论
```