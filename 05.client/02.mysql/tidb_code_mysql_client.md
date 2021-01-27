#1.mysql client

```cpp
main
--my_init
----my_thread_global_init
-=----my_create_thread_local_key
--------pthread_key_create
--------mysql_cond_init
--my_stpcpy(pager, "stdout")

--load_defaults
----my_load_defaults
------init_default_directories
------my_search_option_files
--------get_defaults_options
--------search_default_file
----------search_default_file_with_ext
------------mysql_file_fopen
------------handle_default_option
------my_default_get_login_file
------my_search_option_files (conf_file=0x7fffffffdaf0 "/home/chenhui/.mylogin.cnf

--get_options//mysql.cc
----handle_options

--mysql_server_init//the same with mysqladmin
----my_init

--sql_connect
--signal(SIGINT, handle_ctrlc_signal);
--signal(SIGQUIT, mysql_end);
--signal(SIGHUP, handle_quit_signal);
--signal(SIGWINCH, window_resize);

--read_and_execute
----batch_readline
----find_command
----add_line
----com_go
------mysql_real_query_for_lazy
--------mysql_real_query
--------cli_read_query_result
----------read_ok_ex
```