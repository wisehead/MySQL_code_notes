#1.FSP_HDR page

```cpp
/*          SPACE HEADER
            ============

File space header data structure: this data structure is contained in the
first page of a space. The space for this header is reserved in every extent
descriptor page, but used only in the first. */

/*-------------------------------------*/
#define FSP_SPACE_ID        0   /* space id */
#define FSP_NOT_USED        4   /* this field contained a value up to
                    which we know that the modifications
                    in the database have been flushed to
                    the file space; not used now */
#define FSP_SIZE        8   /* Current size of the space in
                    pages */
#define FSP_FREE_LIMIT      12  /* Minimum page number for which the
                    free list has not been initialized:
                    the pages >= this limit are, by
                    definition, free; note that in a
                    single-table tablespace where size
                    < 64 pages, this number is 64, i.e.,
                    we have initialized the space
                    about the first extent, but have not
                    physically allocted those pages to the
                    file */
#define FSP_SPACE_FLAGS     16  /* fsp_space_t.flags, similar to
                    dict_table_t::flags */
#define FSP_FRAG_N_USED     20  /* number of used pages in the
                    FSP_FREE_FRAG list */
#define FSP_FREE        24  /* list of free extents */
#define FSP_FREE_FRAG       (24 + FLST_BASE_NODE_SIZE)
                    /* list of partially free extents not
                    belonging to any segment */
#define FSP_FULL_FRAG       (24 + 2 * FLST_BASE_NODE_SIZE)
                    /* list of full extents not belonging
                    to any segment */
#define FSP_SEG_ID      (24 + 3 * FLST_BASE_NODE_SIZE)
                    /* 8 bytes which give the first unused
                    segment id */
#define FSP_SEG_INODES_FULL (32 + 3 * FLST_BASE_NODE_SIZE)
                    /* list of pages containing segment
                    headers, where all the segment inode
                    slots are reserved */
#define FSP_SEG_INODES_FREE (32 + 4 * FLST_BASE_NODE_SIZE)
                    /* list of pages containing segment
                    headers, where not all the segment
                    header slots are reserved */
/*-------------------------------------*/
/* File space header size */
#define FSP_HEADER_SIZE     (32 + 5 * FLST_BASE_NODE_SIZE)

#define FSP_FREE_ADD        4   /* this many free extents are added
                    to the free list from above
                    FSP_FREE_LIMIT at a time */
/* @} */


Tablespace Descripter Page（FIL_PAGE_TYPE_FSP_HDR）
表空间的第一个 Page，用来描述表空间。这个 Page 的依然符合 Basic Page 的格式，由上图的 FIL header / trailer 以及 body 组成；这里介绍其 body 部分。

包括：

Part I：Tablespace Header（在代码中叫做 “Filespace Header”，简写做 FSP）

Part II：256个 XDES（Extent Descripter）Entry，每个 Entry 用于描述一个 Extent 的所有 Page，由下节介绍

Part I：Tablespace Header


FSP_SPACE_ID：该文件对应的 tablespace id
FSP_NOT_USED：保留字节，当前未使用
FSP_SIZE：当前表空间数据页总数，扩展文件时需要更新该值（fsp_try_extend_data_file_with_pages）
FSP_FREE_LIMIT：当前尚未初始化的最小 page no。从该页往后的都尚未加入到表空间的 FSP_FREE 上
FSP_SPACE_FLAGS：当前表空间的 flag 信息，见下文
FSP_SEG_ID：当前文件中最大 segment id + 1，用于段分配时的 seg id 计数器
FSP_FRAG_N_USED：FSP_FREE_FRAG 链表上已被使用的页数，用于快速计算该链表上可用空闲页数
*同时的，每一个Tablespace都维护若干（双向）链表：

【Segment 相关】

FSP_SEG_INODES_FULL：已被完全用满的 INODE Page
FSP_SEG_INODES_FREE：存在空闲Entry的 INODE Page
【Extent 和 FRAG PAGE 相关】

FSP_FREE：Extent 中所有页有都未被使用时，放到该链表上
FSP_FREE_FRAG：Extent 中部分页被使用（不属于任何 Segment，被共享使用）
FSP_FULL_FRAG：Extent 中所有页都被使用（不属于任何 Segment，被共享使用）
Part II：XDES Descripter
除了 Tablespace Header，页内还剩余大量空间。这些空间用来描述随后256个 Extent

这部分的 Layout 与 Extent Descripter Page 完全相同，在下小节介绍

```