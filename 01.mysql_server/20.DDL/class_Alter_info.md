#1.class Alter_info

```cpp
/**
  Data describing the table being created by CREATE TABLE or
  altered by ALTER TABLE.
*/

class Alter_info {
 public:
  /**
     Columns, keys and constraints to be dropped.
  */
  Mem_root_array<const Alter_drop *> drop_list;
  // Columns for ALTER_COLUMN_CHANGE_DEFAULT.
  Mem_root_array<const Alter_column *> alter_list;
  // List of keys, used by both CREATE and ALTER TABLE.

  Mem_root_array<Key_spec *> key_list;
  // Keys to be renamed.
  Mem_root_array<const Alter_rename_key *> alter_rename_key_list;

  /// Indexes whose visibilities are to be changed.
  Mem_root_array<const Alter_index_visibility *> alter_index_visibility_list;

  /// List of check constraints whose state is changed.
  Mem_root_array<const Alter_state *> alter_state_list;

  /// Check constraints specification for CREATE and ALTER TABLE operations.
  Sql_check_constraint_spec_list check_constraint_spec_list;

  // List of columns, used by both CREATE and ALTER TABLE.
  List<Create_field> create_list;
  // Type of ALTER TABLE operation.
  ulonglong flags;
  // Enable or disable keys.
  enum_enable_or_disable keys_onoff;
  // List of partitions.
  List<String> partition_names;
  // Number of partitions.
  uint num_parts;
  // Type of ALTER TABLE algorithm.
  enum_alter_table_algorithm requested_algorithm;
  // Type of ALTER TABLE lock.
  enum_alter_table_lock requested_lock;
  /*
    Whether VALIDATION is asked for an operation. Used during virtual GC and
    partitions alterations.
  */
  enum_with_validation with_validation;
  /// "new_db" (if any) or "db" (if any) or default database from
  /// ALTER TABLE [db.]table [ RENAME [TO|AS|=] [new_db.]new_table ]
  LEX_CSTRING new_db_name;

  /// New table name in the "RENAME [TO] <table_name>" clause or NULL_STR
  LEX_CSTRING new_table_name;
     
```