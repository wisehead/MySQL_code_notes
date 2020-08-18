#1. btr_page_alloc

```cpp
--btr_page_alloc
----btr_page_alloc_low
------fseg_alloc_free_page_general
--------fseg_inode_get
--------fseg_alloc_free_page_low
----------xdes_get_descriptor_with_space_hdr
------------xdes_calc_descriptor_page
----------fseg_mark_page_used
----------fsp_page_create
------------buf_page_create
--------------buf_LRU_get_free_block
--------------buf_page_hash_get_low
--------------buf_page_init
--------------buf_LRU_add_block
--------------memset(frame + FIL_PAGE_PREV, 0xff, 4);
--------------memset(frame + FIL_PAGE_NEXT, 0xff, 4);
--------------mach_write_to_2(frame + FIL_PAGE_TYPE, FIL_PAGE_TYPE_ALLOCATED);
--------------memset(frame + FIL_PAGE_FILE_FLUSH_LSN, 0, 8);
------------fsp_init_file_page
--------------fsp_init_file_page_low
----------------memset(page, 0, UNIV_PAGE_SIZE);
----------------mach_write_to_4(page + FIL_PAGE_OFFSET, buf_block_get_page_no(block));
----------------mach_write_to_4(page + FIL_PAGE_ARCH_LOG_NO_OR_SPACE_ID,buf_block_get_space(block));
--------------mlog_write_initial_log_record(MLOG_INIT_FILE_PAGE)
```