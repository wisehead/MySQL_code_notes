#1.lock_external

```
lock_external
--for (i=1 ; i <= count ; i++, tables++)
----if ((*tables)->db_stat & HA_READ_ONLY ||
	((*tables)->reginfo.lock_type >= TL_READ &&
	 (*tables)->reginfo.lock_type <= TL_READ_NO_INSERT))
------lock_type=F_RDLCK;
----if ((error=(*tables)->file->ha_external_lock(thd,lock_type)))
----else
------(*tables)->db_stat &= ~ HA_BLOCK_LOCK;
------(*tables)->current_lock= lock_type;
```