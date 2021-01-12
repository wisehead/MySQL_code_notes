#1.struct mtr_page_buf_t

```cpp
struct mtr_page_buf_t {
    /* space_id of the page_buf */
    uint32_t    space_id;

    /* page_no of the page_buf */
    uint32_t    page_no;

    /* page_lsn of the page_buf */
    lsn_t       page_lsn;

    /* log dyn_buf,same as mtr_t's m_log in original MYSQL */
    mtr_buf_t   log_buf;

    /* NCDB log header */
    mtr_log_header  log_header;

    /* true if need to alloc space for NCDB log header in log_buf */
    bool        need_write_header;

    /* ture if current buffer is NEWed */
    bool        is_new;

    /* set value if the page needs to log checksum */
    byte*       checksum_ptr;

    /* point to extra page within same mtr */
    struct mtr_page_buf_t* next;

};    
```