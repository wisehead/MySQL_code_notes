#1.struct buf_flush_t

```cpp
/** Flags for flush types */
enum buf_flush_t {
  BUF_FLUSH_LRU = 0,     /*!< flush via the LRU list */
  BUF_FLUSH_LIST,        /*!< flush via the flush list
                         of dirty blocks */
  BUF_FLUSH_SINGLE_PAGE, /*!< flush via the LRU list
                         but only a single page */
  BUF_FLUSH_N_TYPES      /*!< index of last element + 1  */
};
```


#2.BUF_FLUSH_LIST

##2.1 buf_do_flush_list_batch

```cpp
buf_do_flush_list_batch
--uf_flush_page_and_try_neighbors(bpage, BUF_FLUSH_LIST, min_n, &count);
```

##2.2 buf_flush_lists

```cpp
buf_flush_lists
--buf_flush_do_batch(buf_pool, BUF_FLUSH_LIST, min_n, lsn_limit,&page_count))
```

##2.3 pc_flush_slot

```cpp
pc_flush_slot
--buf_flush_do_batch(buf_pool, BUF_FLUSH_LIST, slot->n_pages_requested,page_cleaner->lsn_limit, &slot->n_flushed_list);
```

##2.4 buf_flush_page_coordinator_thread

```cpp
buf_flush_page_coordinator_thread
--buf_flush_wait_batch_end(NULL, BUF_FLUSH_LIST);
```

##2.5 buf_flush_sync_all_buf_pools

```cpp
buf_flush_sync_all_buf_pools
--buf_flush_wait_batch_end(NULL, BUF_FLUSH_LIST);
```

##2.6 recv_apply_hashed_log_recs

```cpp
recv_apply_hashed_log_recs
--recv_sys->flush_type = BUF_FLUSH_LIST;
```

#3.BUF_FLUSH_LRU

##3.1 buf_pool_withdraw_blocks

```cpp
buf_pool_withdraw_blocks
--buf_flush_do_batch(buf_pool, BUF_FLUSH_LRU, scan_depth, 0, &n_flushed);
--buf_flush_wait_batch_end(buf_pool, BUF_FLUSH_LRU);
```

##3.2 buf_page_init_low

```cpp
buf_page_init_low
--bpage->flush_type = BUF_FLUSH_LRU;
```
##3.3 buf_flush_LRU_list_batch

```cpp
buf_flush_LRU_list_batch
--buf_flush_ready_for_flush(bpage, BUF_FLUSH_LRU))
--buf_flush_page_and_try_neighbors(bpage, BUF_FLUSH_LRU, max, &count);
```

##3.4 buf_flush_LRU_list

```cpp
buf_flush_LRU_list
--buf_flush_do_batch(buf_pool, BUF_FLUSH_LRU, scan_depth, 0, &n_flushed);
```

##3.5 buf_flush_wait_LRU_batch_end

```cpp
buf_flush_wait_LRU_batch_end
--buf_flush_wait_batch_end(buf_pool, BUF_FLUSH_LRU);
```

##3.6 recv_writer_thread

```cpp
recv_writer_thread
--recv_sys->flush_type = BUF_FLUSH_LRU;
```