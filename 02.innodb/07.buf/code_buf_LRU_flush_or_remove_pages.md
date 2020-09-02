#1.buf_LRU_flush_or_remove_pages

```cpp
/** Flushes all dirty pages or removes all pages belonging
 to a given tablespace. A PROBLEM: if readahead is being started, what
 guarantees that it will not try to read in pages after this operation
 has completed? */
 
buf_LRU_flush_or_remove_pages
--//case BUF_REMOVE_ALL_NO_WRITE:
----buf_LRU_drop_page_hash_for_tablespace
------page_arr[num_entries] = bpage->id.page_no();
------buf_LRU_drop_page_hash_batch(space_id, page_size, page_arr, num_entries);
--------btr_search_drop_page_hash_when_freed
----------buf_page_get_gen
----------btr_search_drop_page_hash_index
------------ahi_slot = ut_fold_ulint_pair(static_cast<ulint>(index_id),static_cast<ulint>(block->page.id.space())) %btr_ahi_parts;
------------ha_remove_all_nodes_to_page//删除指向该page的AHI
--------------ha_chain_get_first
--------------ha_delete_hash_node(table, node);
--------------ha_chain_get_next
--//case BUF_REMOVE_FLUSH_NO_WRITE:
--//case BUF_REMOVE_FLUSH_WRITE:
--buf_LRU_remove_pages
--//case BUF_REMOVE_ALL_NO_WRITE:
----buf_LRU_remove_all_pages(buf_pool, id);
------btr_search_drop_page_hash_when_freed
------buf_flush_remove
------buf_LRU_block_remove_hashed(bpage, true, false)
------buf_LRU_block_free_hashed_page
--//case BUF_REMOVE_FLUSH_NO_WRITE:
----buf_flush_dirty_pages(buf_pool, id, observer, false, NULL, strict);
------buf_flush_or_remove_pages//false
--------buf_flush_or_remove_page//false
----------buf_flush_remove
--------buf_flush_try_yield
----------buf_flush_yield
------------buf_page_set_sticky(bpage);
------------os_thread_yield
------------buf_page_unset_sticky(bpage);
--//case BUF_REMOVE_FLUSH_WRITE:
----buf_flush_dirty_pages(buf_pool, id, observer, true, trx, strict);
------buf_flush_or_remove_pages//true
--------buf_flush_ready_for_flush(bpage, BUF_FLUSH_SINGLE_PAGE)
--------buf_flush_page(buf_pool, bpage, BUF_FLUSH_SINGLE_PAGE, false)
----------os_aio_simulated_wake_handler_threads
```

#2.caller

```cpp
--FlushObserver::flush
--fil_close_tablespace
--Fil_shard::space_delete
--Fil_shard::space_truncate
--mark_all_page_dirty_in_tablespace
--fsp_alter_encrypt_tablespace
--row_quiesce_table_start
```