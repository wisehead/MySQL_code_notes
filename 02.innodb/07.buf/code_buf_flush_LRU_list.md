#1.buf_flush_LRU_list

```cpp
/**
Clears up tail of the LRU list of a given buffer pool instance:
* Put replaceable pages at the tail of LRU to the free list
* Flush dirty pages at the tail of LRU to the disk
The depth to which we scan each buffer pool is controlled by dynamic
config parameter innodb_LRU_scan_depth.
@param buf_pool buffer pool instance
@return total pages flushed */

buf_flush_LRU_list
--buf_get_withdraw_depth
--scan_depth = UT_LIST_GET_LEN(buf_pool->LRU);
--scan_depth = ut_min(static_cast<ulint>(srv_LRU_scan_depth), scan_depth);
--buf_flush_do_batch(buf_pool, BUF_FLUSH_LRU, scan_depth, 0, &n_flushed);
```


#2.caller

```
pc_flush_slot
```