#1.trx_slave_flush_ids

```cpp
trx_slave_flush_ids
--local_end.assign(trx_sys->trx_end_ids.begin(),trx_sys->trx_end_ids.end());
--trx_sys->trx_end_ids.clear();
--clean_id = trx_sys->slave_clean_id;
--max_id = trx_sys->slave_max_trx_id;
--low_limit_no = trx_sys->slave_dyn_low_limit_no;
--if (max_id >= new_max_trx_id)
----new_max_trx_id = max_id + 1;
--trx_slave_flush_ids_add(new_max_trx_id);
--trx_slave_flush_ids_remove
----for (auto id : ids)
------trx_sys->slave_trx_ids_set.erase(id);
----for (auto id : ids)
------trx_sys->slave_trx_init_ids.erase(id)
--local_end.clear()
--trx_sys->max_trx_id = new_max_trx_id
--trx_sys->rw_trx_ids.assign(trx_sys->slave_trx_ids_set.begin(),trx_sys->slave_trx_ids_set.end());
--trx_slave_clean_id
----ids_set->erase(ids_set->begin(), ids_set->lower_bound(trx_id));
----trx_ids->assign(ids_set->begin(), ids_set->end());
--MVCC::update_latest_read_view
--MVCC::close_unref_read_view
```

#2.clean_id = trx_sys->slave_clean_id;

#3.max_id = trx_sys->slave_max_trx_id;


#4.caller

