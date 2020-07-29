#1. btr_pcur_open_at_index_side

```cpp
btr_pcur_open_at_index_side//btr_pcur_t::open_at_side//btr_cur_open_at_index_side_func
--mtr_s_lock(dict_index_get_lock(index), mtr);
--upper_rw_latch = RW_S_LATCH;
--btr_cur_latch_for_root_leaf
--btr_cur_get_page_cur
--btr_page_get_level
----btr_page_get_level_low
------mach_read_from_2(page + PAGE_HEADER + PAGE_LEVEL);
--page_cur_set_before_first
```