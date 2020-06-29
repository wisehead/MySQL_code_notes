#log_file_size code trace

##1 exec
```
18380 | info: Executing '$MYSQLD_CMD $args --innodb-log-group-home-dir=foo\;bar' as '/ssd1/chenhui3/pripath/libexec/mysqld --defaults-group-suffix=.1 --defaults-file=/ssd1/chenhui3/pripath/mysql-test/var/my.cnf   --loose-console --core-file --log-error-ver
      bosity=3 > /ssd1/chenhui3/pripath/mysql-test/var/log/my_restart.err 2>&1 --innodb-log-group-home-dir=foo\;bar'
18381 | >handle_command_error
18382 | | enter: error: 1
18383 | | >var_set
18384 | | | enter: var_name: '__error' = '1' (length: 1)
18388 | | <var_set
18389 | <handle_command_error
18390 | >var_set  
18391 | | enter: var_name: '__error' = '256' (length: 3)
18395 | <var_set  
18396 <do_exec  
```

##2 do_let

```
18420 >do_let       
18425 | >var_set    
18426 | | enter: var_name: 'SEARCH_PATTERN' = 'syntax error in innodb_log_group_home_dir' (length: 41)
18427 | | >eval_expr
18428 | | | enter: p: 'syntax error in innodb_log_group_home_dir'
18429 | | <eval_expr
18430 | <var_set    
18431 <do_let
```

##3 do_source

```cpp
18454 >do_source         
18463 | info: sourcing file: include/search_pattern.inc
18464 | >open_file       
18465 | | enter: name: include/search_pattern.inc
18466 | | >dirname_part  
18467 | | | enter: '/ssd1/chenhui3/pripath/mysql-test/suite/innodb/t/log_file_size.test'
18470 | | <dirname_part  
18471 | | >fn_format     
18472 | | | enter: name: ./include/search_pattern.inc  dir:   extension:   flag: 4
18493 | | <fn_format     
18494 | <open_file       
18495 <do_source 

```

###3.1 do_perl
```cpp
do_perl
--read_until_delimiter
--info: Executing perl:     use strict;
18997 | >create_temp_file
18998 | | enter: dir: /ssd1/chenhui3/pripath/mysql-test/var, prefix: tmp
19008 | >fn_format
19009 | | enter: name: /ssd1/chenhui3/pripath/mysql-test/var/tmpZNiIY9  dir:   extension:   flag: 4
19048 | >handle_command_error
19049 | | enter: error: 0
19050 | | >var_set
19051 | | | enter: var_name: '__error' = '0' (length: 1)
19052 | | | >eval_expr
19053 | | | | enter: p: '0'
19054 | | | <eval_expr
19055 | | <var_set
19056 | <handle_command_error
19057 <do_perl
```

##4 do_remove_file

```
19215 >do_remove_file
19225 | | info: val: /ssd1/chenhui3/pripath/mysql-test/var/log/my_restart.err
19230 | info: removing file: /ssd1/chenhui3/pripath/mysql-test/var/log/my_restart.err
19231 | >my_delete
19232 | | my: name /ssd1/chenhui3/pripath/mysql-test/var/log/my_restart.err MyFlags 0
19233 | <my_delete
19234 | >handle_command_error
19235 | | enter: error: 0
19236 | | >var_set
19237 | | | enter: var_name: '__error' = '0' (length: 1)
19238 | | | >eval_expr
19239 | | | | enter: p: '0'
19240 | | | <eval_expr
19241 | | <var_set
19242 | <handle_command_error
19243 <do_remove_file
```

##5.--error 175,1

```
19314 >read_command
19315 | >read_line
19316 | | info: Starting to read at lineno: 54
19317 | | exit: Found newline in comment at line: 55
19318 | <read_line
19319 | info: query: '--error 175,1'
19320 | info: first_word: error
19321 <read_command
19322 >get_command_type
19323 | >find_type
19324 | | enter: x: 'error'  lib: 0xcbb160
19325 | <find_type
19326 <get_command_type
```

##6.do_exec

```
19348 >do_exec
19349 | enter: cmd: '$MYSQLD_CMD $crash=1 --log-error-verbosity=3'
19350 | >init_dynamic_string
19351 | <init_dynamic_string
19352 | >do_eval
19353 | | >var_get
19354 | | | enter: var_name: $MYSQLD_CMD $crash=1 --log-error-verbosity=3
19355 | | <var_get
19356 | | >var_get
19357 | | | enter: var_name: $crash=1 --log-error-verbosity=3
19358 | | <var_get
19359 | <do_eval
19360 | info: Executing '$MYSQLD_CMD $crash=1 --log-error-verbosity=3' as '/ssd1/chenhui3/pripath/libexec/mysqld --defaults-group-suffix=.1 --defaults-file=/ssd1/chenhui3/pripath/mysql-test/var/my.cnf   --loose-console > /ssd1/chenhui3/pripath/mysql-test/v
      ar/log/my_restart.err 2>&1 --innodb-force-recovery-crash=1 --log-error-verbosity=3'
19361 | >handle_command_error
19362 | | enter: error: 1
19363 | | >var_set
19364 | | | enter: var_name: '__error' = '1' (length: 1)
19365 | | | >eval_expr
19366 | | | | enter: p: '1'
19367 | | | <eval_expr
19368 | | <var_set
19369 | <handle_command_error
19370 | >var_set
19371 | | enter: var_name: '__error' = '256' (length: 3)
19372 | | >eval_expr
19373 | | | enter: p: '256'
19374 | | <eval_expr
19375 | <var_set
19376 <do_exec
```