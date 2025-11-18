#1. trx_undo_page_is_stale

```cpp
trx_undo_page_is_stale
--offs_unuse = trx_undo_page_offs_unused(undo_page + offset);
--if (offs_unuse)
----/** No before image found. Expriment shows: 1%-5% */
----return (true);
--else if (lsn > log_applied_lsn)
----/** Log worker has applied all records about this undo page
    since all records about one page are applied TOGETHER by the
    same worker. Before image must exist. Expriment shows: 10% */
----return (false);
--else
----complete = prpl_mgr->log_group_page_complete(fold);
```