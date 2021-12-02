#1 mysql_alter_table

```cpp
mysql_alter_table
--Query_logger::check_if_log_table
--notify
----ha_notify_alter_table
------plugin_foreach_with_mask
--------plugin_foreach_with_mask
----------notify_alter_table_helper
--open_tables
----open_and_process_routine
----lock_table_names
------for (table= tables_start; table && table != tables_end;table= table->next_global)
--------schema_set.insert(table)
--------mdl_requests.push_front(&table->mdl_request);//type = MDL_SHARED_UPGRADABLE, duration = MDL_TRANSACTION,
------MDL_request *schema_request= new (thd->mem_root) MDL_request;
------MDL_REQUEST_INIT(schema_request,MDL_key::SCHEMA, table->db, "",MDL_INTENTION_EXCLUSIVE,MDL_TRANSACTION);//schema  IX lock
------mdl_requests.push_front(schema_request);
------MDL_REQUEST_INIT(&global_request,MDL_key::GLOBAL, "", "", MDL_INTENTION_EXCLUSIVE,MDL_STATEMENT);//global IX lock
------mdl_requests.push_front(&global_request);
------thd->mdl_context.acquire_locks(&mdl_requests, wait_time) // Phase 3: Acquire the locks which have been requested so far.
------get_and_lock_tablespace_names
--------tablespace_set.insert(const_cast<char*>(table->target_tablespace_name.str)))
--------get_table_and_parts_tablespace_names
--------lock_tablespace_names
----------MDL_REQUEST_INIT(tablespace_request, MDL_key::TABLESPACE,"", tablespace, MDL_INTENTION_EXCLUSIVE,MDL_TRANSACTION);
----------mdl_tablespace_requests.push_front(tablespace_request);
----------thd->mdl_context.acquire_locks(&mdl_tablespace_requests,lock_wait_timeout)
```