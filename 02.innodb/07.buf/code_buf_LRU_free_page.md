#1.buf_LRU_free_page

```cpp
/** Try to free a block.  If bpage is a descriptor of a compressed-only
page, the descriptor object will be freed as well.
NOTE: this function may temporarily release and relock the
buf_page_get_get_mutex(). Furthermore, the page frame will no longer be
accessible via bpage. If this function returns true, it will also release
the LRU list mutex.
The caller must hold the LRU list and buf_page_get_mutex() mutexes.
@param[in]  bpage   block to be freed
@param[in]  zip true if should remove also the compressed page of
                        an uncompressed page
@return true if freed, false otherwise. */


buf_LRU_free_page
--buf_page_can_relocate
----buf_page_get_io_fix(bpage) == BUF_IO_NONE && bpage->buf_fix_count == 0
--buf_page_alloc_descriptor
--buf_page_can_relocate
--buf_LRU_block_remove_hashed//BUF_BLOCK_ZIP_PAGE到此结束
--//BUF_BLOCK_FILE_PAGE继续。
  /* We have just freed a BUF_BLOCK_FILE_PAGE. If b != NULL
  then it was a compressed page with an uncompressed frame and
  we are interested in freeing only the uncompressed frame.
  Therefore we have to reinsert the compressed page descriptor
  into the LRU and page_hash (and possibly flush_list).
  if b == NULL then it was a regular page that has been freed */
--b->state =b->oldest_modification ? BUF_BLOCK_ZIP_DIRTY : BUF_BLOCK_ZIP_PAGE;
--HASH_INSERT(buf_page_t, hash, buf_pool->page_hash, b->id.fold(), b);
--UT_LIST_INSERT_AFTER(buf_pool->LRU, prev_b, b);
--buf_LRU_add_block_low//if prev_b == NULL
--buf_flush_relocate_on_flush_list//BUF_BLOCK_ZIP_DIRTY
----buf_flush_delete_from_flush_rbt(bpage);
------rbt_delete(buf_pool->flush_rbt, &bpage);
----prev_b = buf_flush_insert_in_flush_rbt(dpage);
----UT_LIST_REMOVE(buf_pool->flush_list, bpage);
----UT_LIST_INSERT_AFTER(buf_pool->flush_list, prev, dpage);
--btr_search_drop_page_hash_index
--buf_page_unset_sticky(b);
--buf_LRU_block_free_hashed_page
----buf_LRU_block_free_non_file_page

```