#1.prev_record_reads

```cpp

/*
  Get the number of different row combinations for subset of partial join

  SYNOPSIS
    prev_record_reads()
      join       The join structure
      idx        Number of tables in the partial join order (i.e. the
                 partial join order is in join->positions[0..idx-1])
      found_ref  Bitmap of tables for which we need to find # of distinct
                 row combinations.

  DESCRIPTION
    Given a partial join order (in join->positions[0..idx-1]) and a subset of
    tables within that join order (specified in found_ref), find out how many
    distinct row combinations of subset tables will be in the result of the
    partial join order.
     
    This is used as follows: Suppose we have a table accessed with a ref-based
    method. The ref access depends on current rows of tables in found_ref.
    We want to count # of different ref accesses. We assume two ref accesses
    will be different if at least one of access parameters is different.
    Example: consider a query

    SELECT * FROM t1, t2, t3 WHERE t1.key=c1 AND t2.key=c2 AND t3.key=t1.field

    and a join order:
      t1,  ref access on t1.key=c1
      t2,  ref access on t2.key=c2       
      t3,  ref access on t3.key=t1.field 
    
    For t1: n_ref_scans = 1, n_distinct_ref_scans = 1
    For t2: n_ref_scans = fanout(t1), n_distinct_ref_scans=1
    For t3: n_ref_scans = fanout(t1)*fanout(t2)
            n_distinct_ref_scans = #fanout(t1)
    
    Here "fanout(tx)" is the number of rows read by the access method
    of tx minus rows filtered out by condition filtering
    (pos->filter_effect).

    The reason for having this function (at least the latest version of it)
    is that we need to account for buffering in join execution. 
    
    An edge-case example: if we have a non-first table in join accessed via
    ref(const) or ref(param) where there is a small number of different
    values of param, then the access will likely hit the disk cache and will
    not require any disk seeks.
    
    The proper solution would be to assume an LRU disk cache of some size,
    calculate probability of cache hits, etc. For now we just count
    identical ref accesses as one.

  RETURN 
    Expected number of row combinations
*/

prev_record_reads
--for (POSITION *pos= join->positions + idx - 1; pos != pos_end; pos--)
----const double fanout= pos->rows_fetched * pos->filter_effect;
----if (pos->table->table_ref->map() & found_ref)
------found_ref|= pos->ref_depend_map;
------found*= fanout;
----else if (fanout < 1.0)
------found*= fanout;
```