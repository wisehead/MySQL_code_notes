#1.struct HA_CREATE_INFO

```cpp
/* struct to hold information about the table that should be created */
struct HA_CREATE_INFO {
  const CHARSET_INFO *table_charset{nullptr};
  const CHARSET_INFO *default_table_charset{nullptr};
  LEX_STRING connect_string{nullptr, 0};
  const char *password{nullptr};
  const char *tablespace{nullptr};
  LEX_STRING comment{nullptr, 0};

  /**
  Algorithm (and possible options) to be used for InnoDB's transparent
  page compression. If this attribute is set then it is hint to the
  storage engine to try and compress the data using the specified algorithm
  where possible. Note: this value is interpreted by the storage engine only.
  and ignored by the Server layer. */

  LEX_STRING compress{nullptr, 0};

  /**
  This attibute is used for InnoDB's transparent page encryption.
  If this attribute is set then it is hint to the storage engine to encrypt
  the data. Note: this value is interpreted by the storage engine only.
  and ignored by the Server layer. */

  LEX_STRING encrypt_type{nullptr, 0};

  /**
   * Secondary engine of the table.
   * Is nullptr if no secondary engine defined.
   */
  LEX_CSTRING secondary_engine{nullptr, 0};

  const char *data_file_name{nullptr};
  const char *index_file_name{nullptr};
  const char *alias{nullptr};
  ulonglong max_rows{0};
  ulonglong min_rows{0};
  ulonglong auto_increment_value{0};
  ulong table_options{0};
  ulong avg_row_length{0};
  ulong used_fields{0};
  ulong key_block_size{0};
  uint stats_sample_pages{0}; /* number of pages to sample during
                           stats estimation, if used, otherwise 0. */
  enum_stats_auto_recalc stats_auto_recalc{HA_STATS_AUTO_RECALC_DEFAULT};
  SQL_I_List<TABLE_LIST> merge_list;
  handlerton *db_type{nullptr};
  /**
    Row type of the table definition.

    Defaults to ROW_TYPE_DEFAULT for all non-ALTER statements.
    For ALTER TABLE defaults to ROW_TYPE_NOT_USED (means "keep the current").

    Can be changed either explicitly by the parser.
    If nothing specified inherits the value of the original table (if present).
  */
  enum row_type row_type = ROW_TYPE_DEFAULT;
  uint null_bits{0}; /* NULL bits at start of record */
  uint options{0};   /* OR of HA_CREATE_ options */
  uint merge_insert_method{0};
  ha_storage_media storage_media{HA_SM_DEFAULT}; /* DEFAULT, DISK or MEMORY */
};
```