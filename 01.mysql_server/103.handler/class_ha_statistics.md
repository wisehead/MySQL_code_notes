#1.ha_statistics

```cpp
class ha_statistics
{
public:
  ulonglong data_file_length;       /* Length off data file */
  ulonglong max_data_file_length;   /* Length off data file */
  ulonglong index_file_length;
  ulonglong max_index_file_length;
  ulonglong delete_length;      /* Free bytes */
  ulonglong auto_increment_value;
  /*
    The number of records in the table.
      0    - means the table has exactly 0 rows
    other  - if (table_flags() & HA_STATS_RECORDS_IS_EXACT)
               the value is the exact number of records in the table
             else
               it is an estimate
  */
  ha_rows records;
  ha_rows deleted;          /* Deleted records */
  ulong mean_rec_length;        /* physical reclength */
  ulong create_time;            /* When table was created */
  ulong check_time;
  ulong update_time;
  uint block_size;          /* index block size */

  /*
    number of buffer bytes that native mrr implementation needs,
  */
  uint mrr_length_per_rec;

  ha_statistics():
    data_file_length(0), max_data_file_length(0),
    index_file_length(0), delete_length(0), auto_increment_value(0),
    records(0), deleted(0), mean_rec_length(0), create_time(0),
    check_time(0), update_time(0), block_size(0)
  {}
};
```