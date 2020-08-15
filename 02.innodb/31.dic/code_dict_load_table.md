#1. dict_load_table

```cpp
caller:
--ha_innobase::open

dict_table_open_on_name
--dict_table_check_if_in_cache_low
--dict_load_table
----mtr_start(&mtr);
----dict_table_get_low
------dict_table_check_if_in_cache_low
----dtuple_create
------dtuple_create_from_mem
----dtuple_get_nth_field
----dfield_set_data
----dict_index_copy_types
------dict_index_get_nth_field
------dtuple_get_nth_field
------dfield_get_type
------dict_field_get_col
----btr_pcur_open_on_user_rec_func
------btr_pcur_open_low
----btr_pcur_is_on_user_rec
----rec_get_nth_field_offs_old
----dict_load_table_low
------rec_get_deleted_flag
------rec_get_n_fields_old
------rec_get_nth_field_offs_old
------dict_mem_table_create
----btr_pcur_close
----mtr_commit(&mtr);
----dict_load_columns
----dict_table_add_to_cache
----dict_load_indexes
------dict_load_fields
----dict_load_foreigns
```

#2.dict_load_columns

```cpp
dict_load_columns
--dict_table_get_low("SYS_COLUMNS");
--dtuple_create
--dtuple_get_nth_field
--dfield_set_data
--dict_index_copy_types
--btr_pcur_open_on_user_rec
--btr_pcur_get_rec
--dict_load_column_low
----dict_mem_table_add_col
------dict_add_col_name
------dict_mem_fill_column_struct
--btr_pcur_move_to_next_user_rec
```

