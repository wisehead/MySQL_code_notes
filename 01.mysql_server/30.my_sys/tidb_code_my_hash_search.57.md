#1.my_hash_search

```cpp
my_hash_search
--my_hash_first
----calc_hash(hash, key, length ? length : hash->key_length)
------hash->hash_function
--------cset_hash_sort_adapter//ulong to uint, truncate
----------my_hash_sort_bin
----my_hash_first_from_hash_value
----
```