#1.MVCC::close_unref_read_view

```cpp
caller:
--trx_slave_flush_ids


MVCC::close_unref_read_view
--ReadView * view = UT_LIST_GET_LAST(m_views);
--while(view != latest_slave_view.load())
----pre_view = UT_LIST_GET_PREV(m_view_list, view);
----if (view->ref_count.load() == 0)
------view->close();
------UT_LIST_REMOVE(m_views, view);
------UT_LIST_ADD_LAST(m_free, view);
--//end while
```

