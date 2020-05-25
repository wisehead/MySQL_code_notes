#1. dict_table_open_on_name

```cpp
caller:
--ha_innobase::open

dict_table_open_on_name
--dict_load_table
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
```