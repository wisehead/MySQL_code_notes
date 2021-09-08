#1.threadpool_add_connection

```cpp
threadpool_add_connection
--worker_context.save();
--pthread_setspecific(THR_KEY_mysys, 0);
--my_thread_init
--thread_attach
----thd->thread_stack = (char*)&thd;
----thd->store_globals();
----mysql_socket_set_thread_owner(thd->get_protocol_classic()->get_vio()->mysql_socket);
--vio_peer_addr
--in_tencent_root_whitelist
--thd_prepare_connection
----lex_start
----login_connection
------check_connection
------thd->send_statement_status()
----MYSQL_CONNECTION_START
----prepare_new_connection_state
------alloc_and_copy_thd_dynamic_variables
------thd->set_command(COM_SLEEP);
------thd->init_for_queries();
--------ha_enable_transaction
--------reset_root_defaults
--------get_transaction()->init_mem_root_defaults
--------get_transaction()->xid_state()->reset();
```