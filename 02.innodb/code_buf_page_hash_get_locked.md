#1. buf_page_hash_get_locked

```cpp
buf_page_hash_get_s_locked
--buf_page_hash_get_locked
----hash_get_lock
------hash_get_sync_obj_index
--------hash_calc_hash
--------ut_2pow_remainder(hash_calc_hash(fold, table), table->n_sync_obj)
------hash_get_nth_lock
----rw_lock_s_lock
------rw_lock_s_lock_func
--------rw_lock_s_lock_low
----------rw_lock_lock_word_decr
------------lock->lock_word -= amount;
----hash_lock_s_confirm
----buf_page_hash_get_low
------HASH_SEARCH
```