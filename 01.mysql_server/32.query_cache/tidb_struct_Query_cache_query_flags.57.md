#1.struct Query_cache_query_flags

```cpp
struct Query_cache_query_flags
{
  unsigned int client_long_flag:1;
  unsigned int client_protocol_41:1;
  unsigned int protocol_type:2;
  unsigned int more_results_exists:1;
  unsigned int in_trans:1;
  unsigned int autocommit:1;
  unsigned int pkt_nr;
  uint character_set_client_num;
  uint character_set_results_num;
  uint collation_connection_num;
  ha_rows limit;
  Time_zone *time_zone;
  sql_mode_t sql_mode;
  ulong max_sort_length;
  ulong group_concat_max_len;
  ulong default_week_format;
  ulong div_precision_increment;
  MY_LOCALE *lc_time_names;
};
```