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

--get_options
```