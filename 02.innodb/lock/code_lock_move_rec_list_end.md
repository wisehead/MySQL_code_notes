#1. lock_move_rec_list_end

```cpp
lock_move_rec_list_end
--lock_rec_get_first_on_page
----buf_block_get_lock_hash_val
----HASH_GET_FIRST( lock_sys->rec_hash, hash)
--page_cur_position
--page_cur_set_before_first
--page_cur_move_to_next
--rec_get_heap_no_new
--lock_rec_get_nth_bit
--lock_rec_reset_nth_bit
--lock_reset_lock_and_trx_wait
--rec_get_heap_no_new
--lock_rec_add_to_queue
----//if LOCK_WAIT
----lock_rec_create
------mem_heap_alloc(trx->lock.lock_heap,sizeof(lock_t) + n_bytes));
------HASH_INSERT(lock_t, hash, lock_sys->rec_hash,lock_rec_fold(space, page_no), lock);
------lock_set_lock_and_trx_wait(lock, trx);//事务侧重新等。
------UT_LIST_ADD_LAST(trx_locks, trx->lock.trx_locks, lock);
----//if no LOCK_WAIT
------lock_rec_find_similar_on_page
------lock_rec_set_nth_bit
--page_cur_move_to_next(&cur1);
--page_cur_move_to_next(&cur2);

```