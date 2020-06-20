#1.class Alter_info

```cpp
/**
  Data describing the table being created by CREATE TABLE or
  altered by ALTER TABLE.
*/

class Alter_info
{
public:
  /*
    These flags are set by the parser and describes the type of
    operation(s) specified by the ALTER TABLE statement.

    They do *not* describe the type operation(s) to be executed
    by the storage engine. For example, we don't yet know the
    type of index to be added/dropped.
  */

  // Set for ADD [COLUMN]
  static const uint ALTER_ADD_COLUMN            = 1L <<  0;

  // Set for DROP [COLUMN]
  static const uint ALTER_DROP_COLUMN           = 1L <<  1;

  // Set for CHANGE [COLUMN] | MODIFY [CHANGE]
  // Set by mysql_recreate_table()
  static const uint ALTER_CHANGE_COLUMN         = 1L <<  2;

  // Set for ADD INDEX | ADD KEY | ADD PRIMARY KEY | ADD UNIQUE KEY |
  //         ADD UNIQUE INDEX | ALTER ADD [COLUMN]
  static const uint ALTER_ADD_INDEX             = 1L <<  3;

  // Set for DROP PRIMARY KEY | DROP FOREIGN KEY | DROP KEY | DROP INDEX
  static const uint ALTER_DROP_INDEX            = 1L <<  4;

  // Set for RENAME [TO]
  static const uint ALTER_RENAME                = 1L <<  5;

  // Set for ORDER BY
  static const uint ALTER_ORDER                 = 1L <<  6;

  // Set for table_options
  static const uint ALTER_OPTIONS               = 1L <<  7;
  // Set for ALTER [COLUMN] ... SET DEFAULT ... | DROP DEFAULT
  static const uint ALTER_CHANGE_COLUMN_DEFAULT = 1L <<  8;

  // Set for DISABLE KEYS | ENABLE KEYS
  static const uint ALTER_KEYS_ONOFF            = 1L <<  9;

  // Set for CONVERT TO CHARACTER SET
  static const uint ALTER_CONVERT               = 1L << 10;

  // Set for FORCE
  // Set for ENGINE(same engine)
  // Set by mysql_recreate_table()
  static const uint ALTER_RECREATE              = 1L << 11;

  // Set for ADD PARTITION
  static const uint ALTER_ADD_PARTITION         = 1L << 12;

  // Set for DROP PARTITION
  static const uint ALTER_DROP_PARTITION        = 1L << 13;

  // Set for COALESCE PARTITION
  static const uint ALTER_COALESCE_PARTITION    = 1L << 14;

  // Set for REORGANIZE PARTITION ... INTO
  static const uint ALTER_REORGANIZE_PARTITION  = 1L << 15;

  // Set for partition_options
  static const uint ALTER_PARTITION             = 1L << 16;

  // Set for LOAD INDEX INTO CACHE ... PARTITION
  // Set for CACHE INDEX ... PARTITION
  static const uint ALTER_ADMIN_PARTITION       = 1L << 17;

  // Set for REORGANIZE PARTITION
  static const uint ALTER_TABLE_REORG           = 1L << 18;

  // Set for REBUILD PARTITION
  static const uint ALTER_REBUILD_PARTITION     = 1L << 19;

  // Set for partitioning operations specifying ALL keyword
  static const uint ALTER_ALL_PARTITION         = 1L << 20;

  // Set for REMOVE PARTITIONING
  static const uint ALTER_REMOVE_PARTITIONING   = 1L << 21;

  // Set for ADD FOREIGN KEY
  static const uint ADD_FOREIGN_KEY             = 1L << 22;

  // Set for DROP FOREIGN KEY
  static const uint DROP_FOREIGN_KEY            = 1L << 23;

  // Set for EXCHANGE PARITION
  static const uint ALTER_EXCHANGE_PARTITION    = 1L << 24;

  // Set by Sql_cmd_alter_table_truncate_partition::execute()
  static const uint ALTER_TRUNCATE_PARTITION    = 1L << 25;

  // Set for ADD [COLUMN] FIRST | AFTER
  static const uint ALTER_COLUMN_ORDER          = 1L << 26;


  enum enum_enable_or_disable { LEAVE_AS_IS, ENABLE, DISABLE };

  /**
     The different values of the ALGORITHM clause.
     Describes which algorithm to use when altering the table.
  */
  enum enum_alter_table_algorithm
  {
    // In-place if supported, copy otherwise.
    ALTER_TABLE_ALGORITHM_DEFAULT,

    // In-place if supported, error otherwise.
    ALTER_TABLE_ALGORITHM_INPLACE,

    // Copy if supported, error otherwise.
    ALTER_TABLE_ALGORITHM_COPY
  };


  /**
     The different values of the LOCK clause.
     Describes the level of concurrency during ALTER TABLE.
  */
  enum enum_alter_table_lock
  {
    // Maximum supported level of concurency for the given operation.
    ALTER_TABLE_LOCK_DEFAULT,

    // Allow concurrent reads & writes. If not supported, give erorr.
    ALTER_TABLE_LOCK_NONE,

    // Allow concurrent reads only. If not supported, give error.
    ALTER_TABLE_LOCK_SHARED,

    // Block reads and writes.
    ALTER_TABLE_LOCK_EXCLUSIVE
  };


  // Columns and keys to be dropped.
  List<Alter_drop>              drop_list;
  // Columns for ALTER_COLUMN_CHANGE_DEFAULT.
  List<Alter_column>            alter_list;
  // List of keys, used by both CREATE and ALTER TABLE.
  List<Key>                     key_list;
  // List of columns, used by both CREATE and ALTER TABLE.
  List<Create_field>            create_list;
  // Type of ALTER TABLE operation.
  uint                          flags;
  // Enable or disable keys.
  enum_enable_or_disable        keys_onoff;
  // List of partitions.
  List<char>                    partition_names;
  // Number of partitions.
  uint                          num_parts;
  // Type of ALTER TABLE algorithm.
  enum_alter_table_algorithm    requested_algorithm;
  // Type of ALTER TABLE lock.
  enum_alter_table_lock         requested_lock;        
};
```