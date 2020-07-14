#1.mysqltest main

```cpp
main
--//while (!read_command(&command) && !abort_flag)
--read_command
----read_line
--get_command_type
--do_xx
```


#2.interface

```cpp
* do_source

```

#3.do_get_replace

```cpp
read_command
--read_line
----info: query: '--replace_result $MYSQL_TMP_DIR TMP_DIR $KEYRING_PLUGIN_OPT --plugin-dir=KEYRING_PLUGIN_PATH'
--get_command_type
--do_get_replace
----get_string
------var_get
--------info: var: '$MYSQL_TMP_DIR' -> '/ssd1/chenhui3/pripath/mysql-test/var/tmp'
```

