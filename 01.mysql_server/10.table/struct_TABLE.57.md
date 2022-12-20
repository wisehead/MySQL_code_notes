#1.TABLE

```cpp
struct TABLE
{
  TABLE() {}                               /* Remove gcc warning */
  /*
    Since TABLE instances are often cleared using memset(), do not
    add virtual members and do not inherit from TABLE.
    Otherwise memset() will start overwriting the vtable pointer.
  */

  TABLE_SHARE   *s;
  handler       *file;
  TABLE *next, *prev;

private:
  /**
     Links for the lists of used/unused TABLE objects for the particular
     table in the specific instance of Table_cache (in other words for
     specific Table_cache_element object).
     Declared as private to avoid direct manipulation with those objects.
     One should use methods of I_P_List template instead.
  */
  TABLE *cache_next, **cache_prev;

  /*
    Give Table_cache_element access to the above two members to allow
    using them for linking TABLE objects in a list.
  */
  friend class Table_cache_element;

public:

  THD   *in_use;                        /* Which thread uses this */
  Field **field;                        /* Pointer to fields */
  /// Count of hidden fields, if internal temporary table; 0 otherwise.
  uint hidden_field_count;

  uchar *record[2];                     /* Pointer to records */
  uchar *write_row_record;              /* Used as optimisation in
                                           THD::write_row */
  uchar *insert_values;                  /* used by INSERT ... UPDATE */
  /*
    Map of keys that can be used to retrieve all data from this table
    needed by the query without reading the row.
  */
  key_map covering_keys;
  key_map quick_keys, merge_keys;

  /*
    possible_quick_keys is a superset of quick_keys to use with EXPLAIN of
    JOIN-less commands (single-table UPDATE and DELETE).

    When explaining regular JOINs, we use JOIN_TAB::keys to output the
    "possible_keys" column value. However, it is not available for
    single-table UPDATE and DELETE commands, since they don't use JOIN
    optimizer at the top level. OTOH they directly use the range optimizer,
    that collects all keys usable for range access here.
  */
  key_map possible_quick_keys;
  /*
    A set of keys that can be used in the query that references this
    table.

    All indexes disabled on the table's TABLE_SHARE (see TABLE::s) will be
    subtracted from this set upon instantiation. Thus for any TABLE t it holds
    that t.keys_in_use_for_query is a subset of t.s.keys_in_use. Generally we
    must not introduce any new keys here (see setup_tables).

    The set is implemented as a bitmap.
  */
  key_map keys_in_use_for_query;
  /* Map of keys that can be used to calculate GROUP BY without sorting */
  key_map keys_in_use_for_group_by;
  /* Map of keys that can be used to calculate ORDER BY without sorting */
  key_map keys_in_use_for_order_by;
  KEY  *key_info;                       /* data of keys defined for the table */

  Field *next_number_field;             /* Set if next_number is activated */
  Field *found_next_number_field;       /* Set on open */
  Field **vfield;                       /* Pointer to generated fields*/
  Field *hash_field;                    /* Field used by unique constraint */
  Field *fts_doc_id_field;              /* Set if FTS_DOC_ID field is present */

  /* Table's triggers, 0 if there are no of them */
  Table_trigger_dispatcher *triggers;
  TABLE_LIST *pos_in_table_list;/* Element referring to this table */
  /* Position in thd->locked_table_list under LOCK TABLES */
  TABLE_LIST *pos_in_locked_tables;
  ORDER         *group;
  const char    *alias;                   /* alias or table name */
  uchar         *null_flags;
  my_bitmap_map *bitmap_init_value;
  MY_BITMAP     def_read_set, def_write_set, tmp_set; /* containers */
  /*
    Bitmap of fields that one or more query condition refers to. Only
    used if optimizer_condition_fanout_filter is turned 'on'.
    Currently, only the WHERE clause and ON clause of inner joins is
    taken into account but not ON conditions of outer joins.
    Furthermore, HAVING conditions apply to groups and are therefore
    not useful as table condition filters.
  */
  MY_BITMAP     cond_set;

  /**
    Bitmap of table fields (columns), which are explicitly set in the
    INSERT INTO statement. It is declared here to avoid memory allocation
    on MEM_ROOT).

    @sa fields_set_during_insert.
  */
  MY_BITMAP     def_fields_set_during_insert;

  MY_BITMAP     *read_set, *write_set;          /* Active column sets */

  /**
    A pointer to the bitmap of table fields (columns), which are explicitly set
    in the INSERT INTO statement.

    fields_set_during_insert points to def_fields_set_during_insert
    for base (non-temporary) tables. In other cases, it is NULL.
    Triggers can not be defined for temporary tables, so this bitmap does not
    matter for temporary tables.

    @sa def_fields_set_during_insert.
  */
  MY_BITMAP     *fields_set_during_insert;
  /*
   The ID of the query that opened and is using this table. Has different
   meanings depending on the table type.

   Temporary tables:

   table->query_id is set to thd->query_id for the duration of a statement
   and is reset to 0 once it is closed by the same statement. A non-zero
   table->query_id means that a statement is using the table even if it's
   not the current statement (table is in use by some outer statement).

   Non-temporary tables:

   Under pre-locked or LOCK TABLES mode: query_id is set to thd->query_id
   for the duration of a statement and is reset to 0 once it is closed by
   the same statement. A non-zero query_id is used to control which tables
   in the list of pre-opened and locked tables are actually being used.
  */
  query_id_t    query_id;

  /*
    For each key that has quick_keys.is_set(key) == TRUE: estimate of #records
    and max #key parts that range access would use.
  */
  ha_rows       quick_rows[MAX_KEY];

  /* Bitmaps of key parts that =const for the entire join. */
  key_part_map  const_key_parts[MAX_KEY];

  uint          quick_key_parts[MAX_KEY];
  uint          quick_n_ranges[MAX_KEY];

  /*
    Estimate of number of records that satisfy SARGable part of the table
    condition, or table->file->records if no SARGable condition could be
    constructed.
    This value is used by join optimizer as an estimate of number of records
    that will pass the table condition (condition that depends on fields of
    this table and constants)
  */
  ha_rows       quick_condition_rows;

  uint          lock_position;          /* Position in MYSQL_LOCK.table */
  uint          lock_data_start;        /* Start pos. in MYSQL_LOCK.locks */
  uint          lock_count;             /* Number of locks */
  uint          temp_pool_slot;         /* Used by intern temp tables */
  uint          db_stat;                /* mode of file as in handler.h */
  int           current_lock;           /* Type of lock on table */

private:
  /**
    If true, this table is inner w.r.t. some outer join operation, all columns
    are nullable (in the query), and null_row may be true.
  */
  my_bool nullable;

public:
  /*
    If true, the current table row is considered to have all columns set to
    NULL, including columns declared as "not null" (see nullable).
    @todo make it private, currently join buffering changes it through a pointer
  */
  my_bool null_row;

  uint8   status;                       /* What's in record[0] */
  my_bool copy_blobs;                   /* copy_blobs when storing */
  /*
    TODO: Each of the following flags take up 8 bits. They can just as easily
    be put into one single unsigned long and instead of taking up 18
    bytes, it would take up 4.
  */
  my_bool force_index;

  /**
    Flag set when the statement contains FORCE INDEX FOR ORDER BY
    See TABLE_LIST::process_index_hints().
  */
  my_bool force_index_order;

  /**
    Flag set when the statement contains FORCE INDEX FOR GROUP BY
    See TABLE_LIST::process_index_hints().
  */
  my_bool force_index_group;
  my_bool distinct;
  my_bool const_table;
  my_bool no_rows;

  /**
     If set, the optimizer has found that row retrieval should access index
     tree only.
   */
  my_bool key_read;
  /**
     Certain statements which need the full row, set this to ban index-only
     access.
  */
  my_bool no_keyread;
  my_bool locked_by_logger;
  /**
    If set, indicate that the table is not replicated by the server.
  */
  my_bool no_replicate;
  my_bool locked_by_name;
  my_bool fulltext_searched;
  my_bool no_cache;
  /* To signal that the table is associated with a HANDLER statement */
  my_bool open_by_handler;
  /*
    To indicate that a non-null value of the auto_increment field
    was provided by the user or retrieved from the current record.
    Used only in the MODE_NO_AUTO_VALUE_ON_ZERO mode.
  */
  my_bool auto_increment_field_not_null;
  my_bool insert_or_update;             /* Can be used by the handler */
  my_bool alias_name_used;              /* true if table_name is alias */
  my_bool get_fields_in_item_tree;      /* Signal to fix_field */
  /**
    This table must be reopened and is not to be reused.
    NOTE: The TABLE will not be reopened during LOCK TABLES in
    close_thread_tables!!!
  */
  my_bool m_needs_reopen;
private:
  bool created; /* For tmp tables. TRUE <=> tmp table has been instantiated.*/
public:
  uint max_keys; /* Size of allocated key_info array. */
  /**
     @todo This member should not be declared in-line. That makes it
     impossible for any function that does memory allocation to take a const
     reference to a TABLE object.
   */
  MEM_ROOT mem_root;
  /**
     Initialized in Item_func_group_concat::setup for appropriate
     temporary table if GROUP_CONCAT is used with ORDER BY | DISTINCT
     and BLOB field count > 0.
   */
  Blob_mem_storage *blob_storage;
  GRANT_INFO grant;
  Filesort_info sort;
  partition_info *part_info;            /* Partition related information */
  /* If true, all partitions have been pruned away */
  bool all_partitions_pruned_away;
  MDL_ticket *mdl_ticket;

private:
  /// Cost model object for operations on this table
  Cost_model_table m_cost_model;
...
functions()
...
};      
```