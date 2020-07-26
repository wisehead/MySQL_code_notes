#1.class Alter_table_ctx

```cpp
/** Runtime context for ALTER TABLE. */
class Alter_table_ctx {
 public:
  typedef uint error_if_not_empty_mask;
  static const error_if_not_empty_mask DATETIME_WITHOUT_DEFAULT = 1 << 0;
  static const error_if_not_empty_mask GEOMETRY_WITHOUT_DEFAULT = 1 << 1;

  Create_field *datetime_field;
  error_if_not_empty_mask error_if_not_empty;
  uint tables_opened;
  const char *db;
  const char *table_name;
  const char *alias;
  const char *new_db;
  const char *new_name;
  const char *new_alias;
  char tmp_name[80];

  /* Used to remember which foreign keys already existed in the table. */
  FOREIGN_KEY *fk_info;
  uint fk_count;
  /**
    Maximum number component used by generated foreign key names in the
    old version of table.
  */
  uint fk_max_generated_name_number;
  /**
    Metadata lock request on table's new name when this name or database
    are changed.
  */
  MDL_request target_mdl_request;
  /** Metadata lock request on table's new database if it is changed. */
  MDL_request target_db_mdl_request;

 private:
  char new_filename[FN_REFLEN + 1];
  char new_alias_buff[FN_REFLEN + 1];
  char path[FN_REFLEN + 1];
  char new_path[FN_REFLEN + 1];
  char tmp_path[FN_REFLEN + 1];

#ifndef DBUG_OFF
  /** Indicates that we are altering temporary table. Used only in asserts. */
  bool tmp_table;
#endif
};   
```