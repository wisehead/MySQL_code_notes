#1.btr_create

```cpp
caller:
--dict_create_index_tree_step

btr_create
--fseg_create//non-leaf page segment
----fseg_create_general
--fseg_create//for leaf page segment
----fseg_create_general
------fsp_reserve_free_extents
--page_create
----page_create_write_log
------mlog_write_initial_log_record(MLOG_COMP_PAGE_CREATE)
----page_create_low
------fil_page_set_type(page, FIL_PAGE_INDEX);
```