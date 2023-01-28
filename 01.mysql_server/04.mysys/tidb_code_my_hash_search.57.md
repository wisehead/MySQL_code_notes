#1.my_hash_search

```cpp
my_hash_search
--my_hash_first
----calc_hash(hash, key, length ? length : hash->key_length)
------hash->hash_function
--------cset_hash_sort_adapter//ulong to uint, truncate
----------my_hash_sort_bin
----my_hash_first_from_hash_value
------my_hash_mask
------do
--------pos= dynamic_element(&hash->array,idx,HASH_LINK*)
--------if (!hashcmp(hash,pos,key,length))
----------hashcmp
------------my_hash_key
--------------query_cache_query_get_key
--------if (flag)
----------my_hash_rec_mask
------------calc_hash
--------------cset_hash_sort_adapter
------while ((idx=pos->next) != NO_RECORD);
------*current_record= NO_RECORD;
```