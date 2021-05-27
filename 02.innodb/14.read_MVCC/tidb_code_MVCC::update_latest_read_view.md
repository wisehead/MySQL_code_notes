#1.MVCC::update_latest_read_view

```cpp
caller:
--ncdb_rpl_init_slave
--trx_slave_flush_ids

MVCC::update_latest_read_view
--MVCC::get_view
----if (UT_LIST_GET_LEN(m_free) > 0)
------view = UT_LIST_GET_FIRST(m_free);
----else
------view = UT_NEW_NOKEY(ReadView());
--ReadView::prepare
----m_creator_trx_id = id;
----m_low_limit_id = trx_sys->max_trx_id;
----m_low_limit_no = trx_sys->slave_low_limit_no;
----if (!trx_sys->rw_trx_ids.empty())
------copy_trx_ids(trx_sys->rw_trx_ids);
----else
------m_ids.clear();
----if (UT_LIST_GET_LEN(trx_sys->serialisation_list) > 0)
------trx = UT_LIST_GET_FIRST(trx_sys->serialisation_list);
------if (trx->no < m_low_limit_no)
--------m_low_limit_no = trx->no;
--ReadView::complete
----m_up_limit_id = !m_ids.empty() ? m_ids.front() : m_low_limit_id;
--latest_slave_view.store(new_view) ;
--UT_LIST_ADD_FIRST(m_views, latest_slave_view.load());
```

