#1.dict_table_remove_from_cache_low


caller
- dict_table_remove_from_cache
- innodb_internal_table_validate


#2. innodb_internal_table_validate

```cpp
static MYSQL_SYSVAR_STR(ft_aux_table, fts_internal_tbl_name,
  PLUGIN_VAR_NOCMDARG | PLUGIN_VAR_MEMALLOC,
  "FTS internal auxiliary table to be checked",
  innodb_internal_table_validate,
  NULL, NULL);
```

#3. dict_table_remove_from_cache

caller:

```cpp
- commit_inplace_instant_cache
- commit_inplace_alter_table
```
