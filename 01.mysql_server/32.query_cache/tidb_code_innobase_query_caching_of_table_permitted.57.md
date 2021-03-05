#1.innobase_query_caching_of_table_permitted

```cpp
/*      BACKGROUND INFO: HOW THE MYSQL QUERY CACHE WORKS WITH INNODB
        ------------------------------------------------------------

1) The use of the query cache for TBL is disabled when there is an
uncommitted change to TBL.

2) When a change to TBL commits, InnoDB stores the current value of
its global trx id counter, let us denote it by INV_TRX_ID, to the table object
in the InnoDB data dictionary, and does only allow such transactions whose
id <= INV_TRX_ID to use the query cache.

3) When InnoDB does an INSERT/DELETE/UPDATE to a table TBL, or an implicit
modification because an ON DELETE CASCADE, we invalidate the MySQL query cache
of TBL immediately.

How this is implemented inside InnoDB:

1) Since every modification always sets an IX type table lock on the InnoDB
table, it is easy to check if there can be uncommitted modifications for a
table: just check if there are locks in the lock list of the table.

2) When a transaction inside InnoDB commits, it reads the global trx id
counter and stores the value INV_TRX_ID to the tables on which it had a lock.

3) If there is an implicit table change from ON DELETE CASCADE or SET NULL,
InnoDB calls an invalidate method for the MySQL query cache for that table.

How this is implemented inside sql_cache.cc:

1) The query cache for an InnoDB table TBL is invalidated immediately at an
INSERT/UPDATE/DELETE, just like in the case of MyISAM. No need to delay
invalidation to the transaction commit.

2) To store or retrieve a value from the query cache of an InnoDB table TBL,
any query must first ask InnoDB's permission. We must pass the thd as a
parameter because InnoDB will look at the trx id, if any, associated with
that thd. Also the full_name which is used as key to search for the table
object. The full_name is a string containing the normalized path to the
table in the canonical format.

3) Use of the query cache for InnoDB tables is now allowed also when
AUTOCOMMIT==0 or we are inside BEGIN ... COMMIT. Thus transactions no longer
put restrictions on the use of the query cache.
*/

/******************************************************************//**
The MySQL query cache uses this to check from InnoDB if the query cache at
the moment is allowed to operate on an InnoDB table. The SQL query must
be a non-locking SELECT.

The query cache is allowed to operate on certain query only if this function
returns TRUE for all tables in the query.

If thd is not in the autocommit state, this function also starts a new
transaction for thd if there is no active trx yet, and assigns a consistent
read view to it if there is no read view yet.

Why a deadlock of threads is not possible: the query cache calls this function
at the start of a SELECT processing. Then the calling thread cannot be
holding any InnoDB semaphores. The calling thread is holding the
query cache mutex, and this function will reserve the InnoDB trx_sys->mutex.
Thus, the 'rank' in sync0mutex.h of the MySQL query cache mutex is above
the InnoDB trx_sys->mutex.
@return TRUE if permitted, FALSE if not; note that the value FALSE
does not mean we should invalidate the query cache: invalidation is
called explicitly */



innobase_query_caching_of_table_permitted
--normalize_table_name
--innobase_register_trx
----trans_register_ha
----trx_is_registered_for_2pc
----trx_register_for_2pc
--row_search_check_if_query_cache_permitted
----table = dict_table_open_on_name
----trx_start_if_not_started
------trx_start_if_not_started_low
--------trx_start_low
----MVCC::view_open
----dict_table_close

```

