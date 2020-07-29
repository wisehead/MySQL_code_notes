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
--page_cur_move_to_next
--page_cur_get_rec
--rec_get_offsets_func
----rec_init_offsets
------rec_init_offsets_comp_ordinary
--row_build_w_add_vcol
----row_build_low
------dtuple_create_with_vcol
------dict_table_copy_types
--------dict_table_copy_v_types//virtual columns
--dtuple_set_info_bits

```