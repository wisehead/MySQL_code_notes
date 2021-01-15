#1. mysqladmin for lsn

```cpp
main
--mysql_init
----mysql_server_init//libmysql.c:109
------my_init
------init_client_errs
--------my_error_register
------mysql_client_plugin_init
--------for (builtin= mysql_client_builtins; *builtin; builtin++)
----------add_plugin_noargs//mysql_native_password
------------do_add_plugin
--------//end for






--execute_commands
----get_pidfile
------mysql_query
--------mysql_real_query//SELECT @@datadir, @@pid_file
----------cli_read_query_result
------------read_com_query_metadata
--------------cli_read_metadata
----------------cli_read_metadata_ex
----mysql_query
------mysql_real_query
--------mysql_send_query
--------cli_read_query_result
----------read_ok_ex
------------net_field_length_ll_safe
--------------net_field_length_size
--------------buffer_check_remaining
--------------net_field_length_ll
------------buffer_check_remaining
----------MYSQL_TRACE_STAGE(mysql, WAIT_FOR_RESULT);
----wait_pidfile
------my_open
------my_close
------stat
```