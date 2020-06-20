#1.struct HA_CREATE_INFO

```cpp
typedef struct st_ha_create_information
{
  const CHARSET_INFO *table_charset, *default_table_charset;
  LEX_STRING connect_string;
  const char *password, *tablespace;
  LEX_STRING comment;
  const char *data_file_name, *index_file_name;
  const char *alias;
  ulonglong max_rows,min_rows;
  ulonglong auto_increment_value;
  ulong table_options;
  ulong avg_row_length;
  ulong used_fields;
  ulong key_block_size;
  uint stats_sample_pages;      /* number of pages to sample during
                    stats estimation, if used, otherwise 0. */
  enum_stats_auto_recalc stats_auto_recalc;
  SQL_I_List<TABLE_LIST> merge_list;
  handlerton *db_type;
  /**
    Row type of the table definition.

    Defaults to ROW_TYPE_DEFAULT for all non-ALTER statements.
    For ALTER TABLE defaults to ROW_TYPE_NOT_USED (means "keep the current").

    Can be changed either explicitly by the parser.
    If nothing speficied inherits the value of the original table (if present).
  */
  enum row_type row_type;
  uint null_bits;                       /* NULL bits at start of record */
  uint options;             /* OR of HA_CREATE_ options */
  uint merge_insert_method;
  uint extra_size;                      /* length of extra data segment */
  bool varchar;                         /* 1 if table has a VARCHAR */
  enum ha_storage_media storage_media;  /* DEFAULT, DISK or MEMORY */
} HA_CREATE_INFO;
```