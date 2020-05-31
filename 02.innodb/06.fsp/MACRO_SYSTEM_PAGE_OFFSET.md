#1.MACRO SYSTEM page offset

```cpp
/** @name The space low address page map
The pages at FSP_XDES_OFFSET and FSP_IBUF_BITMAP_OFFSET are repeated
every XDES_DESCRIBED_PER_PAGE pages in every tablespace. */
/* @{ */
/*--------------------------------------*/
#define FSP_XDES_OFFSET         0   /* !< extent descriptor */
#define FSP_IBUF_BITMAP_OFFSET      1   /* !< insert buffer bitmap */
                /* The ibuf bitmap pages are the ones whose
                page number is the number above plus a
                multiple of XDES_DESCRIBED_PER_PAGE */

#define FSP_FIRST_INODE_PAGE_NO     2   /*!< in every tablespace */
                /* The following pages exist
                in the system tablespace (space 0). */
#define FSP_IBUF_HEADER_PAGE_NO     3   /*!< insert buffer
                        header page, in
                        tablespace 0 */
#define FSP_IBUF_TREE_ROOT_PAGE_NO  4   /*!< insert buffer
                        B-tree root page in
                        tablespace 0 */
                /* The ibuf tree root page number in
                tablespace 0; its fseg inode is on the page
                number FSP_FIRST_INODE_PAGE_NO */
#define FSP_TRX_SYS_PAGE_NO     5   /*!< transaction
                        system header, in
                        tablespace 0 */
#define FSP_FIRST_RSEG_PAGE_NO      6   /*!< first rollback segment
                        page, in tablespace 0 */
#define FSP_DICT_HDR_PAGE_NO        7   /*!< data dictionary header
                        page, in tablespace 0 */
/*--------------------------------------*/
/* @} */
```