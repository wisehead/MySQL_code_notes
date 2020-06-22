#1.row_ins_step

```cpp
caller:
--que_thr_step

row_ins_step
--trx_write_trx_id
--lock_table
----lock_table_has
----lock_table_other_has_incompatible
----lock_table_create
--row_ins
----row_ins_alloc_row_id_step
----row_ins_index_entry_step
------row_ins_index_entry_set_vals
------row_ins_index_entry
--------row_ins_clust_index_entry
----------row_ins_clust_index_entry_low
------------btr_cur_search_to_nth_level
------------btr_cur_optimistic_insert
```