#1.lock_clust_rec_cons_read_sees

```cpp
caller:
--row_search_for_mysql


lock_clust_rec_cons_read_sees
--row_get_rec_trx_id
----trx_read_trx_id
------mach_read_from_6
--changes_visible
```