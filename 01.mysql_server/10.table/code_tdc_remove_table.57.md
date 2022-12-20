#1.tdc_remove_table

```cpp
/**
   Remove all or some (depending on parameter) instances of TABLE and
   TABLE_SHARE from the table definition cache.

   @param  thd          Thread context
   @param  remove_type  Type of removal:
                        TDC_RT_REMOVE_ALL     - remove all TABLE instances and
                                                TABLE_SHARE instance. There
                                                should be no used TABLE objects
                                                and caller should have exclusive
                                                metadata lock on the table.
                        TDC_RT_REMOVE_NOT_OWN - remove all TABLE instances
                                                except those that belong to
                                                this thread. There should be
                                                no TABLE objects used by other
                                                threads and caller should have
                                                exclusive metadata lock on the
                                                table.
                        TDC_RT_REMOVE_UNUSED  - remove all unused TABLE
                                                instances (if there are no
                                                used instances will also
                                                remove TABLE_SHARE).
                        TDC_RT_REMOVE_NOT_OWN_KEEP_SHARE -
                                                remove all TABLE instances
                                                except those that belong to
                                                this thread, but don't mark
                                                TABLE_SHARE as old. There
                                                should be no TABLE objects
                                                used by other threads and
                                                caller should have exclusive
                                                metadata lock on the table.
   @param  db           Name of database
   @param  table_name   Name of table
   @param  has_lock     If TRUE, LOCK_open is already acquired

   @note It assumes that table instances are already not used by any
   (other) thread (this should be achieved by using meta-data locks).
*/

tdc_remove_table
--if (! has_lock)
----Table_cache_manager::lock_all_and_tdc
--create_table_def_key
----key_length= strmake(strmake(key, db_name, NAME_LEN) +1, table_name, NAME_LEN) - key + 1;
--if ((share= (TABLE_SHARE*) my_hash_search(&table_def_cache,(uchar*) key,key_length)))
----if (share->ref_count)
------table_cache_manager.free_table(thd, remove_type, share)
----else
------my_hash_delete(&table_def_cache, (uchar*) share);
--if (! has_lock)
----table_cache_manager.unlock_all_and_tdc()
```