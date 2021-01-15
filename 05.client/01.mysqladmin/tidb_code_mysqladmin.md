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
----------add_plugin_noargs//"mysql_clear_password","mysql_native_password","sha256_password"
------------do_add_plugin
--------------sha256_password_init//init function for the plugin
--------//end for
------mysql_port = MYSQL_PORT;
------mysql_unix_port = (char*) MYSQL_UNIX_ADDR;
----mysql_extension_init

--load_defaults
----my_load_defaults
------init_default_directories
------my_search_option_files//my.cnf
--------get_defaults_options
--------search_default_file
------my_default_get_login_file
------my_search_option_files//mylogin.cnf
--------get_defaults_options
--------search_default_file
----------search_default_file_with_ext

--handle_options
----get_one_option
----"-S"
----"-u"
----"-p"
----"kill" (*argv)[argvpos ++]= cur_arg
----"10"

--mask_password
--(void) signal(SIGINT,endprog)
--(void) signal(SIGTERM,endprog)
--set_client_ssl_options
----mysql_ssl_set

--sql_connect
----mysql_real_connect
------my_socket sock= socket(AF_UNIX, SOCK_STREAM, 0)
------vio_new
--------mysql_socket_setfd
--------mysql_socket_vio_new
----------vio_init
------vio_socket_connect
--------inline_mysql_socket_connect
----------connect(mysql_socket.fd, addr, len)//linux os api
------my_net_init
------cli_safe_read
------run_plugin_auth
--------auth_plugin= &native_password_client_plugin
--------auth_plugin_name= auth_plugin->name;
--------check_plugin_enabled
--------native_password_auth_client
----------vio->write_packet(vio, (uchar*)scrambled, SCRAMBLE_LENGTH)//用scrambled随机序列加密密码

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