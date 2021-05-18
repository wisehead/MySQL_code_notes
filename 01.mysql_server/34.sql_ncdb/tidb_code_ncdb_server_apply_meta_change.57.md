#1.ncdb_server_apply_meta_change

```cpp
ncdb_server_apply_meta_change
--switch(type)
----case META_CHANGE_START:
------ncdb_acquire_mdl
----case META_CHANGE_END:
------ncdb_release_mdl

```


#2.caller

```
NCDB_DDL_Opr_Ctl::ncdb_apply_meta_change
```