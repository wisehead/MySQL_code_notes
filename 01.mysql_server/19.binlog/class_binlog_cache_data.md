#1.binlog_cache_data

```cpp
/**
  Caches for non-transactional and transactional data before writing
  it to the binary log.

  @todo All the access functions for the flags suggest that the
  encapsuling is not done correctly, so try to move any logic that
  requires access to the flags into the cache.
*/
class binlog_cache_data
{
public:
  /*
    Cache to store data before copying it to the binary log.
  */
  IO_CACHE cache_log;

  /**
    The group cache for this cache.
  */
  Group_cache group_cache;
  struct Flags {
    /*
      Defines if this is either a trx-cache or stmt-cache, respectively, a
      transactional or non-transactional cache.
    */
    bool transactional:1;

    /*
      This indicates that some events did not get into the cache and most likely
      it is corrupted.
    */
    bool incident:1;

    /*
      This indicates that the cache should be written without BEGIN/END.
    */
    bool immediate:1;

    /*
      This flag indicates that the buffer was finalized and has to be
      flushed to disk.
     */
    bool finalized:1;

    /*
      This indicates that the cache contain an XID event.
     */
    bool with_xid:1;
  } flags;

private:
  /*
    Pending binrows event. This event is the event where the rows are currently
    written.
   */
  Rows_log_event *m_pending;
  /*
    Stores the values of maximum size of the cache allowed when this cache
    is configured. This corresponds to either
      . max_binlog_cache_size or max_binlog_stmt_cache_size.
  */
  my_off_t saved_max_binlog_cache_size;

  /*
    Stores a pointer to the status variable that keeps track of the in-memory
    cache usage. This corresponds to either
      . binlog_cache_use or binlog_stmt_cache_use.
  */
  ulong *ptr_binlog_cache_use;

  /*
    Stores a pointer to the status variable that keeps track of the disk
    cache usage. This corresponds to either
      . binlog_cache_disk_use or binlog_stmt_cache_disk_use.
  */
  ulong *ptr_binlog_cache_disk_use;
};    
```