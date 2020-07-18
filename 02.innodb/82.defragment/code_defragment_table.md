#1.defragment_table

```cpp
caller:
--ha_innobase::optimize

ha_innobase::defragment_table
--normalize_table_name
--dict_table_open_on_name
--btr_defragment_find_index
--btr_defragment_add_index
----btr_block_get(space, zip_size, page_no, RW_NO_LATCH, index, &mtr);//get root page
----btr_pcur_create_for_mysql

```