#1.Sql_cmd_delete::mysql_delete

```cpp
caller:
mysql_execute_command
--Sql_cmd_delete::execute


Sql_cmd_delete::mysql_delete
--open_tables_for_query
----open_tables
--handler::ha_delete_row
----ha_innobase::delete_row
------row_update_for_mysql
--------row_update_for_mysql_using_upd_graph
----------row_upd_step
------------row_upd
--------------row_upd_clust_step
----------------row_upd_del_mark_clust_rec
------------------btr_cur_del_mark_set_clust_rec
--------------------trx_undo_report_row_operation
----------------------trx_undo_assign_undo
------------------------trx_undo_reuse_cached
--------------------------trx_undo_header_create
----------------------------trx_undo_header_create_log
------------------------------mlog_write_initial_log_record// MLOG_UNDO_HDR_CREATE
--------------------------trx_undo_header_add_space_for_xid
----------------------------mlog_write_ulint//MLOG_2BYTES
------------------------mtr_t::commit
```