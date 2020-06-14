#1. FLST_BASE_NODE and FLST_NODE

在InnoDB里链表头称为`FLST_BASE_NODE`，大小为`FLST_BASE_NODE_SIZE`(16个字节)。BASE NODE维护了链表的头指针和末尾指针，每个节点称为`FLST_NODE`，大小为`FLST_NODE_SIZE`（12个字节）。相关结构描述如下：

`FLST_BASE_NODE`:

| Macro | bytes | Desc |
| --- | --- | --- |
| FLST\_LEN | 4 | 存储链表的长度 |
| FLST\_FIRST | 6 | 指向链表的第一个节点 |
| FLST\_LAST | 6 | 指向链表的最后一个节点 |

`FLST_NODE`:

| Macro | bytes | Desc |
| --- | --- | --- |
| FLST\_PREV | 6 | 指向当前节点的前一个节点 |
| FLST\_NEXT | 6 | 指向当前节点的下一个节点 |

如上所述，文件链表中使用6个字节来作为节点指针，指针的内容包括：

| Macro | bytes | Desc |
| --- | --- | --- |
| FIL\_ADDR\_PAGE | 4 | Page No |
| FIL\_ADDR\_BYTE | 2 | Page内的偏移量 |

#2. flst_node_t

```cpp
/* The C 'types' of base node and list node: these should be used to
write self-documenting code. Of course, the sizeof macro cannot be
applied to these types! */

typedef byte    flst_base_node_t;
typedef byte    flst_node_t;

/* The physical size of a list base node in bytes */
#define FLST_BASE_NODE_SIZE (4 + 2 * FIL_ADDR_SIZE)

/* The physical size of a list node in bytes */
#define FLST_NODE_SIZE      (2 * FIL_ADDR_SIZE)

```

#3. fil_addr_t

```cpp
/* Space address data type; this is intended to be used when
addresses accurate to a byte are stored in file pages. If the page part
of the address is FIL_NULL, the address is considered undefined. */

typedef byte    fil_faddr_t;    /*!< 'type' definition in C: an address
                stored in a file page is a string of bytes */
#define FIL_ADDR_PAGE   0   /* first in address is the page offset */
#define FIL_ADDR_BYTE   4   /* then comes 2-byte byte offset within page*/

#define FIL_ADDR_SIZE   6   /* address size is 6 bytes */

/** File space address */
struct fil_addr_t{
    ulint   page;       /*!< page number within a space */
    ulint   boffset;    /*!< byte offset within the page */
};

```