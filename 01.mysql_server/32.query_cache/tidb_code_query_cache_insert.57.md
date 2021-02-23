#1.query_cache_insert

```cpp
/*****************************************************************************
  Functions to store things into the query cache
*****************************************************************************/

/*
  Note on double-check locking (DCL) usage.

  Below, in query_cache_insert(), query_cache_abort() and
  Query_cache::end_of_result() we use what is called double-check
  locking (DCL) for Query_cache_tls::first_query_block.
  I.e. we test it first without a lock, and, if positive, test again
  under the lock.

  This means that if we see 'first_query_block == 0' without a
  lock we will skip the operation.  But this is safe here: when we
  started to cache a query, we called Query_cache::store_query(), and
  'first_query_block' was set to non-zero in this thread (and the
  thread always sees results of its memory operations, mutex or not).
  If later we see 'first_query_block == 0' without locking a
  mutex, that may only mean that some other thread have reset it by
  invalidating the query.  Skipping the operation in this case is the
  right thing to do, as first_query_block won't get non-zero for
  this query again.

  See also comments in Query_cache::store_query() and
  Query_cache::send_result_to_client().

  NOTE, however, that double-check locking is not applicable in
  'invalidate' functions, as we may erroneously skip invalidation,
  because the thread doing invalidation may never see non-zero
  'first_query_block'.
*/


query_cache_insert
--Query_cache::insert
```