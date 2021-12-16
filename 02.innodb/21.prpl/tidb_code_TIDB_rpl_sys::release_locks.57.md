#1.NCDB_rpl_sys::release_locks

```cpp
NCDB_rpl_sys::release_locks
--ddl_opr_ctl->ncdb_apply_meta_clear()
----ddl_table_set.clear();
--ncdb_release_all_mdls
----thd->mdl_context.release_explicit_locks();
```

#2.m_recv_ddl_lsn

#3.set_recv_ddl_lsn

```cpp
//从库刚加入进来的时候，主库会回一个resp，包括dict recovery lsn
ncdb_node::login
--ncdb_node::login_in_slave
----set_recv_ddl_lsn
```