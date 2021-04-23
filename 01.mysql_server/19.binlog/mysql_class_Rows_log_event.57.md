#1.class Rows_log_event

```cpp
/**
  @class Rows_log_event

 Common base class for all row-containing log events.

 RESPONSIBILITIES

   Encode the common parts of all events containing rows, which are:
   - Write data header and data body to an IO_CACHE.

  Virtual inheritance is required here to handle the diamond problem in
  the class Write_rows_log_event, Update_rows_log_event and
  Delete_rows_log_event.
  The diamond structure is explained in @Write_rows_log_event,
                                        @Update_rows_log_event,
                                        @Delete_rows_log_event

  @internal
  The inheritance structure in the current design for the classes is
  as follows:

        Binary_log_event
               ^
               |
               |
         Rows_event  Log_event
                \       /
          <<vir>>\     /
                  \   /
              Rows_log_event
  @endinternal

*/
class Rows_log_event : public virtual binary_log::Rows_event, public Log_event
{
  uint     m_row_count;         /* The number of rows added to the event */
#ifdef MYSQL_SERVER
  TABLE *m_table;               /* The table the rows belong to */
#endif
  MY_BITMAP   m_cols;           /* Bitmap denoting columns available */
#ifndef MYSQL_CLIENT
  /**
     Hash table that will hold the entries for while using HASH_SCAN
     algorithm to search and update/delete rows.
   */
  Hash_slave_rows m_hash;

  /**
     The algorithm to use while searching for rows using the before
     image.
  */
  uint            m_rows_lookup_algorithm;
#endif
  /*
    Bitmap for columns available in the after image, if present. These
    fields are only available for Update_rows events. Observe that the
    width of both the before image COLS vector and the after image
    COLS vector is the same: the number of columns of the table on the
    master.
  */
  MY_BITMAP   m_cols_ai;

  ulong       m_master_reclength; /* Length of record on master side */

  /* Bit buffers in the same memory as the class */
  uint32    m_bitbuf[128/(sizeof(uint32)*8)];
  uint32    m_bitbuf_ai[128/(sizeof(uint32)*8)];

  /*
   is_valid depends on the value of m_rows_buf, so while changing the value
   of m_rows_buf check if is_valid also needs to be modified
  */
  uchar    *m_rows_buf;         /* The rows in packed format */
  uchar    *m_rows_cur;         /* One-after the end of the data */
  uchar    *m_rows_end;         /* One-after the end of the allocated space */


  /* helper functions */

#if defined(MYSQL_SERVER) && defined(HAVE_REPLICATION)
  const uchar *m_curr_row;     /* Start of the row being processed */
  const uchar *m_curr_row_end; /* One-after the end of the current row */
  uchar    *m_key;      /* Buffer to keep key value during searches */
  uint     m_key_index;
  KEY      *m_key_info; /* Points to description of index #m_key_index */
  std::set<uchar *, Key_compare> m_distinct_keys;
  std::set<uchar *, Key_compare>::iterator m_itr;
  /**
    A spare buffer which will be used when saving the distinct keys
    for doing an index scan with HASH_SCAN search algorithm.
  */
  uchar *m_distinct_key_spare_buf;
};  
```