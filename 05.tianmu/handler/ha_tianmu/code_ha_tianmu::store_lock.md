#1.ha_tianmu::store_lock

```
ha_tianmu::store_lock
--if (lock_type != TL_IGNORE && lock_.type == TL_UNLOCK)
----lock_.type = lock_type;
--*to++ = &lock_;
--return to;
```

#2.caller 
```
get_lock_data
```
