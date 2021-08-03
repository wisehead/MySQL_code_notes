#1.fil_truncate_tablespace

```cpp
fil_truncate_tablespace
--fil_prepare_for_truncate
----fil_check_pending_operations
------/* Check for pending operations. */
------while (count > 0)//check and wait
--------count = fil_check_pending_ops(sp, count);
------/* Check for pending IO. */
------while (count > 0)
--------fil_check_pending_io
--buf_LRU_flush_or_remove_pages
--ncdb_truncate_space(space_id);
```