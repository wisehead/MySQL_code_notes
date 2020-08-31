#1.prpl_sys_t::recycle_mem

```cpp
prpl_log_coordinator_thread
--prpl_sys.recycle_mem(TRUE)
----prpl_rec_hash::get_apply_lsn
----apply_lsn.store(apply_cur_lsn);
----log_rec_buf_mgr_t::recycle_buf
------//if (buf->shredded_all.load() && buf->end_lsn.load() <= lwm)
------UT_LIST_REMOVE(used_list, buf);
------UT_LIST_ADD_FIRST(free_list, buf);
----prpl_mem_heap::recycle_chunk
------if (chunk->full.load() && chunk->recycle_lsn.load() <= lwm)
------
```