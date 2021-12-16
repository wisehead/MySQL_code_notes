#1.NCDB_DDL_Opr_Ctl::ncdb_apply_meta_change

```cpp
NCDB_DDL_Opr_Ctl::ncdb_apply_meta_change
--build_table_filename
--normalize_table_name
--if (type == META_CHANGE_END)
----ncdb_apply_meta_del(norm_name)
------ddl_table_set.erase(std::string(table_name));
--ncdb_server_apply_meta_change
--if (need_evict)
----innobase_evict_dict_cache(db, object_name)
--if (type == META_CHANGE_START)
----ncdb_apply_meta_add(norm_name);

```

#2.caller
```
NCDB_DDL_Opr_Ctl::ncdb_parse_meta_change
```