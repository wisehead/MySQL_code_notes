#1.TABLE_SHARE

```cpp
/**
  This structure is shared between different table objects. There is one
  instance of table share per one table in the database.
*/

struct TABLE_SHARE
{
  TABLE_SHARE() {}                    /* Remove gcc warning */

  /** Category of this table. */
  TABLE_CATEGORY table_category;

  /* hash of field names (contains pointers to elements of field array) */
  HASH  name_hash;          /* hash of field names */
  MEM_ROOT mem_root;
  TYPELIB keynames;         /* Pointers to keynames */
  TYPELIB fieldnames;           /* Pointer to fieldnames */
  TYPELIB *intervals;           /* pointer to interval info */
  mysql_mutex_t LOCK_ha_data;           /* To protect access to ha_data */
  TABLE_SHARE *next, **prev;            /* Link to unused shares */
  /**
    Array of table_cache_instances pointers to elements of table caches
    respresenting this table in each of Table_cache instances.
    Allocated along with the share itself in alloc_table_share().
    Each element of the array is protected by Table_cache::m_lock in the
    corresponding Table_cache. False sharing should not be a problem in
    this case as elements of this array are supposed to be updated rarely.
  */
  Table_cache_element **cache_element;

  /* The following is copied to each TABLE on OPEN */
  Field **field;
  Field **found_next_number_field;
  KEY  *key_info;           /* data of keys defined for the table */
  uint  *blob_field;            /* Index to blobs in Field arrray*/

  uchar *default_values;        /* row with default values */
  LEX_STRING comment;           /* Comment about table */
  const CHARSET_INFO *table_charset;    /* Default charset of string fields */

  MY_BITMAP all_set;
  /*
    Key which is used for looking-up table in table cache and in the list
    of thread's temporary tables. Has the form of:
      "database_name\0table_name\0" + optional part for temporary tables.

    Note that all three 'table_cache_key', 'db' and 'table_name' members
    must be set (and be non-zero) for tables in table cache. They also
    should correspond to each other.
    To ensure this one can use set_table_cache() methods.
  */
  LEX_STRING table_cache_key;
  LEX_STRING db;                        /* Pointer to db */
  LEX_STRING table_name;                /* Table name (for open) */
  LEX_STRING path;                  /* Path to .frm file (from datadir) */
  LEX_STRING normalized_path;       /* unpack_filename(path) */
  LEX_STRING connect_string;

  /*
     Set of keys in use, implemented as a Bitmap.
     Excludes keys disabled by ALTER TABLE ... DISABLE KEYS.
  */
  key_map keys_in_use;
  key_map keys_for_keyread;
  ha_rows min_rows, max_rows;       /* create information */
  ulong   avg_row_length;       /* create information */
  ulong   version;
  ulong   mysql_version;        /* 0 if .frm is created before 5.0 */
  ulong   reclength;            /* Recordlength */

  plugin_ref db_plugin;         /* storage engine plugin */
  enum row_type row_type;       /* How rows are stored */
  enum tmp_table_type tmp_table;

  uint ref_count;                       /* How many TABLE objects uses this */
  uint key_block_size;          /* create key_block_size, if used */
  uint stats_sample_pages;      /* number of pages to sample during
                    stats estimation, if used, otherwise 0. */
  enum_stats_auto_recalc stats_auto_recalc; /* Automatic recalc of stats. */
  uint null_bytes, last_null_bit_pos;
  uint fields;              /* Number of fields */
  uint rec_buff_length;                 /* Size of table->record[] buffer */
  uint keys;                            /* Number of keys defined for the table*/
  uint key_parts;                       /* Number of key parts of all keys
                                           defined for the table
                                        */
  uint max_key_length;                  /* Length of the longest key */
  uint max_unique_length;               /* Length of the longest unique key */
  uint total_key_length;
  uint uniques;                         /* Number of UNIQUE index */
  uint null_fields;         /* number of null fields */
  uint blob_fields;         /* number of blob fields */
  uint varchar_fields;                  /* number of varchar fields */
  uint db_create_options;       /* Create options from database */
  uint db_options_in_use;       /* Options in use */
  uint db_record_offset;        /* if HA_REC_IN_SEQ */
  uint rowid_field_offset;      /* Field_nr +1 to rowid field */
  /* Primary key index number, used in TABLE::key_info[] */
  uint primary_key;
  uint next_number_index;               /* autoincrement key number */
  uint next_number_key_offset;          /* autoinc keypart offset in a key */
  uint next_number_keypart;             /* autoinc keypart number in a key */
  uint error, open_errno, errarg;       /* error from open_table_def() */
  uint column_bitmap_size;
  uchar frm_version;
  bool null_field_first;
  bool system;                          /* Set if system table (one record) */
  bool crypted;                         /* If .frm file is crypted */
  bool db_low_byte_first;       /* Portable row format */
  bool crashed;
  bool is_view;
  Table_id table_map_id;                   /* for row-based replication */

  /*
    Cache for row-based replication table share checks that does not
    need to be repeated. Possible values are: -1 when cache value is
    not calculated yet, 0 when table *shall not* be replicated, 1 when
    table *may* be replicated.
  */
  int cached_row_logging_check;
  /*
    Storage media to use for this table (unless another storage
    media has been specified on an individual column - in versions
    where that is supported)
  */
  enum ha_storage_media default_storage_media;

  /* Name of the tablespace used for this table */
  char *tablespace;

#ifdef WITH_PARTITION_STORAGE_ENGINE
  /* filled in when reading from frm */
  bool auto_partitioned;
  char *partition_info_str;
  uint  partition_info_str_len;
  uint  partition_info_buffer_size;
  handlerton *default_part_db_type;
#endif

  /**
    Cache the checked structure of this table.

    The pointer data is used to describe the structure that
    a instance of the table must have. Each element of the
    array specifies a field that must exist on the table.

    The pointer is cached in order to perform the check only
    once -- when the table is loaded from the disk.
  */
  const TABLE_FIELD_DEF *table_field_def_cache;

  /** Main handler's share */
  Handler_share *ha_share;

  /** Instrumentation for this table share. */
  PSI_table_share *m_psi;

  /**
    List of tickets representing threads waiting for the share to be flushed.
  */
  Wait_for_flush_list m_flush_tickets;
  /**
    For shares representing views File_parser object with view
    definition read from .FRM file.
  */
  const File_parser *view_def;            
};  
```