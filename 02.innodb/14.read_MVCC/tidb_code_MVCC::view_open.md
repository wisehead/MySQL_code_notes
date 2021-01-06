#1.MVCC::view_open

```cpp
caller:
--trx_assign_read_view

MVCC::view_open
--if (ncdb_slave_mode())
----view = latest_slave_view.load();
----view->ref_count.fetch_add(1);
```