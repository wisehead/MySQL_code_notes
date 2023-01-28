#1.struct st_io_cache/IO_CACHE


```cpp

typedef struct st_io_cache      /* Used when cacheing files */
{
  /* Offset in file corresponding to the first byte of uchar* buffer. */
  my_off_t pos_in_file;
  /*
    The offset of end of file for READ_CACHE and WRITE_CACHE.
    For SEQ_READ_APPEND it the maximum of the actual end of file and
    the position represented by read_end.
  */
  my_off_t end_of_file;
  /* Points to current read position in the buffer */
  uchar *read_pos;
  /* the non-inclusive boundary in the buffer for the currently valid read */
  uchar  *read_end;
  uchar  *buffer;               /* The read buffer */
  /* Used in ASYNC_IO */
  uchar  *request_pos;

  /* Only used in WRITE caches and in SEQ_READ_APPEND to buffer writes */
  uchar  *write_buffer;


  /*
    Only used in SEQ_READ_APPEND, and points to the current read position
    in the write buffer. Note that reads in SEQ_READ_APPEND caches can
    happen from both read buffer (uchar* buffer) and write buffer
    (uchar* write_buffer).
  */
  uchar *append_read_pos;
  /* Points to current write position in the write buffer */
  uchar *write_pos;
  /* The non-inclusive boundary of the valid write area */
  uchar *write_end;

  /*
    Current_pos and current_end are convenience variables used by
    my_b_tell() and other routines that need to know the current offset
    current_pos points to &write_pos, and current_end to &write_end in a
    WRITE_CACHE, and &read_pos and &read_end respectively otherwise
  */
  uchar  **current_pos, **current_end;

  /*
    The lock is for append buffer used in SEQ_READ_APPEND cache
    need mutex copying from append buffer to read buffer.
  */
  mysql_mutex_t append_buffer_lock;
  /*
    The following is used when several threads are reading the
    same file in parallel. They are synchronized on disk
    accesses reading the cached part of the file asynchronously.
    It should be set to NULL to disable the feature.  Only
    READ_CACHE mode is supported.
  */
  IO_CACHE_SHARE *share;
  /*
    Specifies the type of the cache. Depending on the type of the cache
    certain operations might not be available and yield unpredicatable
    results. Details to be documented later
  */
  enum cache_type type;
  /*
    Callbacks when the actual read I/O happens. These were added and
    are currently used for binary logging of LOAD DATA INFILE - when a
    block is read from the file, we create a block create/append event, and
    when IO_CACHE is closed, we create an end event. These functions could,
    of course be used for other things
  */
  IO_CACHE_CALLBACK pre_read;
  IO_CACHE_CALLBACK post_read;
  IO_CACHE_CALLBACK pre_close;
  /*
    Counts the number of times, when we were forced to use disk. We use it to
    increase the binlog_cache_disk_use and binlog_stmt_cache_disk_use status
    variables.
  */
  ulong disk_writes;
  void* arg;                /* for use by pre/post_read */
  char *file_name;          /* if used with 'open_cached_file' */
  char *dir,*prefix;
  File file; /* file descriptor */
  PSI_file_key file_key; /* instrumented file key */

  /*
    seek_not_done is set by my_b_seek() to inform the upcoming read/write
    operation that a seek needs to be preformed prior to the actual I/O
    error is 0 if the cache operation was successful, -1 if there was a
    "hard" error, and the actual number of I/O-ed bytes if the read/write was
    partial.
  */
  int   seek_not_done,error;
  /* buffer_length is memory size allocated for buffer or write_buffer */
  size_t    buffer_length;
  /* read_length is the same as buffer_length except when we use async io */
  size_t  read_length;
  myf   myflags;            /* Flags used to my_read/my_write */
  /*
    alloced_buffer is 1 if the buffer was allocated by init_io_cache() and
    0 if it was supplied by the user.
    Currently READ_NET is the only one that will use a buffer allocated
    somewhere else
  */
  my_bool alloced_buffer;
  
} IO_CACHE;
  
```