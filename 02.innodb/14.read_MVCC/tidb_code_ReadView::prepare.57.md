#1.ReadView::prepare

```cpp
ReadView::prepare
--m_creator_trx_id = id;
--m_low_limit_id = trx_sys->max_trx_id;
--if (ncdb_slave_mode())
----m_low_limit_no = trx_sys->slave_low_limit_no;
--else
----m_low_limit_no = trx_sys->max_trx_id;

```