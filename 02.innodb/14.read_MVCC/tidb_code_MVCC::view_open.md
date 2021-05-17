#1.MVCC::view_open

```cpp
caller:
--trx_assign_read_view
--row_search_check_if_query_cache_permitted

MVCC::view_open
--if (ncdb_slave_mode())
----view = latest_slave_view.load();
----view->ref_count.fetch_add(1);
--if (view != NULL)
----uintptr_t       p = reinterpret_cast<uintptr_t>(view);
----view = reinterpret_cast<ReadView*>(p & ~1);//最后一位是标志位，清空表示可用。
----if (trx_is_autocommit_non_locking(trx) && view->empty())
------
```