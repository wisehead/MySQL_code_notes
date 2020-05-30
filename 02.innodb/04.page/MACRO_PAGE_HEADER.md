#1.MACRO PAGE_HEADER

```cpp
/*          PAGE HEADER
            ===========

Index page header starts at the first offset left free by the FIL-module */

typedef byte        page_header_t;

#define PAGE_HEADER FSEG_PAGE_DATA  /* index page header starts at this
                offset */
/*-----------------------------*/
#define PAGE_N_DIR_SLOTS 0  /* number of slots in page directory */
#define PAGE_HEAP_TOP    2  /* pointer to record heap top */
#define PAGE_N_HEAP  4  /* number of records in the heap,
                bit 15=flag: new-style compact page format */
#define PAGE_FREE    6  /* pointer to start of page free record list */
#define PAGE_GARBAGE     8  /* number of bytes in deleted records */
#define PAGE_LAST_INSERT 10 /* pointer to the last inserted record, or
                NULL if this info has been reset by a delete,
                for example */
#define PAGE_DIRECTION   12 /* last insert direction: PAGE_LEFT, ... */
#define PAGE_N_DIRECTION 14 /* number of consecutive inserts to the same
                direction */
#define PAGE_N_RECS  16 /* number of user records on the page */
#define PAGE_MAX_TRX_ID  18 /* highest id of a trx which may have modified
                a record on the page; trx_id_t; defined only
                in secondary indexes and in the insert buffer
                tree */
#define PAGE_HEADER_PRIV_END 26 /* end of private data structure of the page
                header which are set in a page create */
/*----*/
#define PAGE_LEVEL   26 /* level of the node in an index tree; the
                leaf level is the level 0.  This field should
                not be written to after page creation. */
#define PAGE_INDEX_ID    28 /* index id where the page belongs.
                This field should not be written to after
                page creation. */
#define PAGE_BTR_SEG_LEAF 36    /* file segment header for the leaf pages in
                a B-tree: defined only on the root page of a
                B-tree, but not in the root of an ibuf tree */
                
```

#2. PAGE_DIR

```cpp
//注意page dir是逆序的，从后向前。

/* Offset of the directory start down from the page end. We call the
slot with the highest file address directory start, as it points to
the first record in the list of records. */
#define PAGE_DIR        FIL_PAGE_DATA_END

/* We define a slot in the page directory as two bytes */
#define PAGE_DIR_SLOT_SIZE  2

/* The offset of the physically lower end of the directory, counted from
page end, when the page is empty */
#define PAGE_EMPTY_DIR_START    (PAGE_DIR + 2 * PAGE_DIR_SLOT_SIZE)

define FIL_PAGE_DATA_END   8   /*!< size of the page trailer */

Gets pointer to nth directory slot.
@return pointer to dir slot */
UNIV_INLINE
page_dir_slot_t*
page_dir_get_nth_slot(
/*==================*/
    const page_t*   page,   /*!< in: index page */
    ulint       n)  /*!< in: position */
{
    ut_ad(page_dir_get_n_slots(page) > n);

    return((page_dir_slot_t*)
           page + UNIV_PAGE_SIZE - PAGE_DIR
           - (n + 1) * PAGE_DIR_SLOT_SIZE);
}
```