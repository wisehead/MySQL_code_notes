#1.fts_parse_sql

```cpp
caller:
--fts_write_node

fts_parse_sql
--fts_get_table_name
----fts_get_table_name_low
------fts_get_table_name_prefix
--------fts_get_table_name_prefix_low
--dd_table_open_on_name_in_mem
----dict_table_check_if_in_cache_low
----dict_table_t::acquire
--pars_sql
----yyparse


```