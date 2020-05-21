#1.init_read_record

```cpp
caller:
--join_init_read_record


/*
  init_read_record is used to scan by using a number of different methods.
  Which method to use is set-up in this call so that later calls to
  the info->read_record will call the appropriate method using a function
  pointer.

  There are five methods that relate completely to the sort function
  filesort. The result of a filesort is retrieved using read_record
  calls. The other two methods are used for normal table access.

  The filesort will produce references to the records sorted, these
  references can be stored in memory or in a temporary file.

  The temporary file is normally used when the references doesn't fit into
  a properly sized memory buffer. For most small queries the references
  are stored in the memory buffer.
  SYNOPSIS
    init_read_record()
      info              OUT read structure
      thd               Thread handle
      table             Table the data [originally] comes from.
      select            SQL_SELECT structure. We may select->quick or
                        select->file as data source
      use_record_cache  Call file->extra_opt(HA_EXTRA_CACHE,...)
                        if we're going to do sequential read and some
                        additional conditions are satisfied.
      print_error       Copy this to info->print_error
      disable_rr_cache  Don't use rr_from_cache (used by sort-union
                        index-merge which produces rowid sequences that
                        are already ordered)

  DESCRIPTION
    This function sets up reading data via one of the methods:

  The temporary file is also used when performing an update where a key is
  modified.

  Methods used when ref's are in memory (using rr_from_pointers):
    rr_unpack_from_buffer:
    ----------------------
      This method is used when table->sort.addon_field is allocated.
      This is allocated for most SELECT queries not involving any BLOB's.
      In this case the records are fetched from a memory buffer.
    rr_from_pointers:
    -----------------
      Used when the above is not true, UPDATE, DELETE and so forth and
      SELECT's involving BLOB's. It is also used when the addon_field
      buffer is not allocated due to that its size was bigger than the
      session variable max_length_for_sort_data.
      In this case the record data is fetched from the handler using the
      saved reference using the rnd_pos handler call.

  Methods used when ref's are in a temporary file (using rr_from_tempfile)
    rr_unpack_from_tempfile:
    ------------------------
      Same as rr_unpack_from_buffer except that references are fetched from
      temporary file. Should obviously not really happen other than in
      strange configurations.

    rr_from_tempfile:
    -----------------
      Same as rr_from_pointers except that references are fetched from
      temporary file instead of from
    rr_from_cache:
    --------------
      This is a special variant of rr_from_tempfile that can be used for
      handlers that is not using the HA_FAST_KEY_READ table flag. Instead
      of reading the references one by one from the temporary file it reads
      a set of them, sorts them and reads all of them into a buffer which
      is then used for a number of subsequent calls to rr_from_cache.
      It is only used for SELECT queries and a number of other conditions
      on table size.

  All other accesses use either index access methods (rr_quick) or a full
  table scan (rr_sequential).
  rr_quick:
  ---------
    rr_quick uses one of the QUICK_SELECT classes in opt_range.cc to
    perform an index scan. There are loads of functionality hidden
    in these quick classes. It handles all index scans of various kinds.
  rr_sequential:
  --------------
    This is the most basic access method of a table using rnd_init,
    ha_rnd_next and rnd_end. No indexes are used.

  @retval true   error
  @retval false  success
*/
    
init_read_record
--handler::ha_rnd_init
----ha_innobase::rnd_init
------ha_innobase::change_active_index
--------dtuple_set_n_fields
--------dict_index_copy_types
----------dict_field_get_col
----------dict_col_copy_type
```