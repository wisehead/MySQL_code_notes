#1.Field_long::store

```
Field_long::store
--get_int(cs, from, len, &rnd, UINT_MAX32, INT_MIN32, INT_MAX32);
----Field_num::get_int
--store_tmp= unsigned_flag ? (long) (ulonglong) rnd : (long) rnd;
--longstore(ptr, store_tmp);
----int4store
```