#1.NCDB_DDL_Opr_Ctl::ncdb_parse_meta_change


```cpp
NCDB_DDL_Opr_Ctl::ncdb_parse_meta_change
```

#2.caller

```cpp
parse_or_apply_log_rec_body
--meta_log_type type = static_cast<meta_log_type>(mach_read_from_1(ptr));
--mdl_type = (MDL_key::enum_mdl_namespace)mach_read_from_1(ptr + 1);
--int db_len = mach_read_from_4(ptr + 2);
--int table_len = mach_read_from_4(ptr + 6);
--ptr += 10;
--memcpy((void *)db, (void *)ptr, db_len);
--db[db_len] = '\0';
--ptr += db_len;
--memcpy((void *)object_name, (void *)ptr, table_len);
--object_name[table_len] = '\0';
--ptr += table_len;
--if (ncdb_slave_mode())
----NCDB_DDL_Opr_Ctl::ncdb_apply_meta_change
```