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

#2.Ali Kernal FSP\_HDR PAGE

数据文件的第一个Page类型为`FIL_PAGE_TYPE_FSP_HDR`，在创建一个新的表空间时进行初始化(`fsp_header_init`)，该page同时用于跟踪随后的256个Extent(约256MB文件大小)的空间管理，所以每隔256MB就要创建一个类似的数据页，类型为`FIL_PAGE_TYPE_XDES` ，XDES Page除了文件头部外，其他都和`FSP_HDR`页具有相同的数据结构，可以称之为Extent描述页，每个Extent占用40个字节，一个XDES Page最多描述256个Extent。

`FSP_HDR`页的头部使用`FSP_HEADER_SIZE`个字节来记录文件的相关信息，具体的包括：

| Macro | bytes | Desc |
| --- | --- | --- |
| FSP\_SPACE\_ID | 4 | 该文件对应的space id |
| FSP\_NOT\_USED | 4 | 如其名，保留字节，当前未使用 |
| FSP\_SIZE | 4 | 当前表空间总的PAGE个数，扩展文件时需要更新该值（`fsp_try_extend_data_file_with_pages`） |
| FSP\_FREE\_LIMIT | 4 | 当前尚未初始化的最小Page No。从该Page往后的都尚未加入到表空间的FREE LIST上。 |
| FSP\_SPACE\_FLAGS | 4 | 当前表空间的FLAG信息，见下文 |
| FSP\_FRAG\_N\_USED | 4 | FSP\_FREE\_FRAG链表上已被使用的Page数，用于快速计算该链表上可用空闲Page数 |
| FSP\_FREE | 16 | 当一个Extent中所有page都未被使用时，放到该链表上，可以用于随后的分配 |
| FSP\_FREE\_FRAG | 16 | FREE\_FRAG链表的Base Node，通常这样的Extent中的Page可能归属于不同的segment，用于segment frag array page的分配（见下文） |
| FSP\_FULL\_FRAG | 16 | Extent中所有的page都被使用掉时，会放到该链表上，当有Page从该Extent释放时，则移回FREE\_FRAG链表 |
| FSP\_SEG\_ID | 8 | 当前文件中最大Segment ID + 1，用于段分配时的seg id计数器 |
| FSP\_SEG\_INODES\_FULL | 16 | 已被完全用满的Inode Page链表 |
| FSP\_SEG\_INODES\_FREE | 16 | 至少存在一个空闲Inode Entry的Inode Page被放到该链表上 |

在文件头使用FLAG（对应上述`FSP_SPACE_FLAGS`）描述了创建表时的如下关键信息：

| Macro | Desc |
| --- | --- |
| FSP\_FLAGS\_POS\_ZIP\_SSIZE | 压缩页的block size，如果为0表示非压缩表 |
| FSP\_FLAGS\_POS\_ATOMIC\_BLOBS | 使用的是compressed或者dynamic的行格式 |
| FSP\_FLAGS\_POS\_PAGE\_SSIZE | Page Size |
| FSP\_FLAGS\_POS\_DATA\_DIR | 如果该表空间显式指定了data\_dir，则设置该flag |
| FSP\_FLAGS\_POS\_SHARED | 是否是共享的表空间，如5.7引入的General Tablespace，可以在一个表空间中创建多个表 |
| FSP\_FLAGS\_POS\_TEMPORARY | 是否是临时表空间 |
| FSP\_FLAGS\_POS\_ENCRYPTION | 是否是加密的表空间，MySQL 5.7.11引入 |
| FSP\_FLAGS\_POS\_UNUSED | 未使用的位 |

