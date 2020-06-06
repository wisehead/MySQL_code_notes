#1.MACRO FIL_PAGE_TYPE

```cpp
/** File page types (values of FIL_PAGE_TYPE) @{ */
#define FIL_PAGE_INDEX      17855   /*!< B-tree node */
#define FIL_PAGE_UNDO_LOG   2   /*!< Undo log page */
#define FIL_PAGE_INODE      3   /*!< Index node */
#define FIL_PAGE_IBUF_FREE_LIST 4   /*!< Insert buffer free list */
/* File page types introduced in MySQL/InnoDB 5.1.7 */
#define FIL_PAGE_TYPE_ALLOCATED 0   /*!< Freshly allocated page */
#define FIL_PAGE_IBUF_BITMAP    5   /*!< Insert buffer bitmap */
#define FIL_PAGE_TYPE_SYS   6   /*!< System page */
#define FIL_PAGE_TYPE_TRX_SYS   7   /*!< Transaction system data */
#define FIL_PAGE_TYPE_FSP_HDR   8   /*!< File space header */
#define FIL_PAGE_TYPE_XDES  9   /*!< Extent descriptor page */
#define FIL_PAGE_TYPE_BLOB  10  /*!< Uncompressed BLOB page */
#define FIL_PAGE_TYPE_ZBLOB 11  /*!< First compressed BLOB page */
#define FIL_PAGE_TYPE_ZBLOB2    12  /*!< Subsequent compressed BLOB page */
#define FIL_PAGE_TYPE_LAST  FIL_PAGE_TYPE_ZBLOB2
                    /*!< Last page type */
/* @} */
```