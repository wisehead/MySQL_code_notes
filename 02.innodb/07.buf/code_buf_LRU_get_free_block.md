#1.buf_LRU_get_free_block

```cpp
/** Returns a free block from the buf_pool. The block is taken off the
free list. If free list is empty, blocks are moved from the end of the
LRU list to the free list.
This function is called from a user thread when it needs a clean
block to read in a page. Note that we only ever get a block from
the free list. Even when we flush a page or find a page in LRU scan
we put it to free list to be used.
* iteration 0:
  * get a block from free list, success:done
  * if buf_pool->try_LRU_scan is set
    * scan LRU up to srv_LRU_scan_depth to find a clean block
    * the above will put the block on free list
    * success:retry the free list
  * flush one dirty page from tail of LRU to disk
    * the above will put the block on free list
    * success: retry the free list
* iteration 1:
  * same as iteration 0 except:
    * scan whole LRU list
    * scan LRU list even if buf_pool->try_LRU_scan is not set
* iteration > 1:
  * same as iteration 1 but sleep 10ms
@param[in,out]  buf_pool    buffer pool instance
@return the free control block, in state BUF_BLOCK_READY_FOR_USE */

buf_LRU_get_free_block
--buf_LRU_check_size_of_non_data_objects
--buf_LRU_get_free_only
----UT_LIST_GET_FIRST(buf_pool->free
----UT_LIST_REMOVE(buf_pool->free, &block->page)
----buf_block_set_state(block, BUF_BLOCK_READY_FOR_USE);
----UNIV_MEM_ALLOC(block->frame, UNIV_PAGE_SIZE);
--memset(&block->page.zip, 0, sizeof block->page.zip);
--buf_LRU_scan_and_free_block//从LRU中move一部分block到free list
----buf_LRU_free_from_unzip_LRU_list
------buf_LRU_evict_from_unzip_LRU
------buf_LRU_free_page(&block->page, false);
----buf_LRU_free_from_common_LRU_list
------buf_LRU_free_page
--buf_flush_single_page_from_LRU
----buf_flush_page
------buf_flush_write_block_low
--------log_write_up_to
--------buf_flush_init_for_writing
--------fil_io
--------if (sync) fil_flush
----buf_LRU_free_page

```


#2.caller

```cpp
--buf_buddy_alloc_low
--buf_block_alloc
--Buf_fetch<T>::zip_page_handler
--buf_page_init_for_read
--buf_page_create
```