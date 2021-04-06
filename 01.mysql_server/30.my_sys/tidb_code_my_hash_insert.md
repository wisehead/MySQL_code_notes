#1.my_hash_insert

```cpp
my_hash_insert
--empty=(HASH_LINK*) alloc_dynamic(&info->array)
--data=dynamic_element(&info->array,0,HASH_LINK*);//放在array【0】
--halfbuff= info->blength >> 1;
--idx=first_index=info->records-halfbuff;
--if (idx != info->records)
----do
------pos=data+idx;
------rec_hashnr
--------my_hash_key
----------query_cache_query_get_key
--------calc_hash(hash,key,length)
------if (flag == 0)
--------if (my_hash_mask(hash_nr, info->blength, info->records) != first_index)
------
```

