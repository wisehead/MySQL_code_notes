#1.do_source

```cpp
do_source
--check_command_args
--open_file
----dirname_part
----fn_format
----fopen
--dynstr_free
```

#2.trace
```
>do_source         
| >check_command_args
| | enter: num_args: 1
| | >init_dynamic_string
| | <init_dynamic_string
| | >do_eval       
| | <do_eval       
| | info: val: include/search_pattern.inc
| <check_command_args
| info: sourcing file: include/search_pattern.inc
| >open_file       
| | enter: name: include/search_pattern.inc
| | >dirname_part  
| | | enter: '/ssd1/chenhui3/pripath/mysql-test/suite/innodb/t/log_file_size.test'
| | | >convert_dirname
| | | <convert_dirname
| | <dirname_part  
| | >fn_format     
| | | enter: name: ./include/search_pattern.inc  dir:   extension:   flag: 4
| | | >dirname_part
| | | | enter: './include/search_pattern.inc'
| | | | >convert_dirname
| | | | <convert_dirname
| | | <dirname_part
| | | >unpack_dirname
| | | | >normalize_dirname
| | | | | >dirname_part
| | | | | | enter: './include/'
| | | | | | >convert_dirname
| | | | | | <convert_dirname
| | | | | <dirname_part
| | | | | >cleanup_dirname
| | | | | | enter: from: './include/'
| | | | | | exit: to: './include/'
| | | | | <cleanup_dirname
| | | | <normalize_dirname
| | | <unpack_dirname
| | | >strlength   
| | | <strlength   
| | <fn_format     
| <open_file       
<do_source 
```