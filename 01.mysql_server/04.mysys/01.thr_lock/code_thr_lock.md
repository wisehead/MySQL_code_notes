#1.thr_lock

```
thr_lock
--MYSQL_START_TABLE_LOCK_WAIT(locker, &state, data->m_psi,
                              PSI_TABLE_LOCK, lock_type);
--if ((int) lock_type <= (int) TL_READ_NO_INSERT) 
----if (lock->write.data)
----else if (!lock->write_wait.data ||
	     lock->write_wait.data->type <= TL_WRITE_LOW_PRIORITY ||
	     lock_type == TL_READ_HIGH_PRIORITY ||
	     has_old_lock(lock->read.data, data->owner)) /* Has old read lock */
    {						/* No important write-locks */
------(*lock->read.last)=data;			/* Add to running FIFO */
------data->prev=lock->read.last;
------lock->read.last= &data->next;                           
--MYSQL_END_TABLE_LOCK_WAIT(locker);
```