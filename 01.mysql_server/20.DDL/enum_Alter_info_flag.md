#1.enum Alter_info_flag

```cpp
  /*
    These flags are set by the parser and describes the type of
    operation(s) specified by the ALTER TABLE statement.

    They do *not* describe the type operation(s) to be executed
    by the storage engine. For example, we don't yet know the
    type of index to be added/dropped.
  */

  enum Alter_info_flag : ulonglong {
    /// Set for ADD [COLUMN]
    ALTER_ADD_COLUMN = 1ULL << 0,

    /// Set for DROP [COLUMN]
    ALTER_DROP_COLUMN = 1ULL << 1,

    /// Set for CHANGE [COLUMN] | MODIFY [CHANGE]
    /// Set by mysql_recreate_table()
    ALTER_CHANGE_COLUMN = 1ULL << 2,

    /// Set for ADD INDEX | ADD KEY | ADD PRIMARY KEY | ADD UNIQUE KEY |
    ///         ADD UNIQUE INDEX | ALTER ADD [COLUMN]
    ALTER_ADD_INDEX = 1ULL << 3,

    /// Set for DROP PRIMARY KEY | DROP FOREIGN KEY | DROP KEY | DROP INDEX
    ALTER_DROP_INDEX = 1ULL << 4,

    /// Set for RENAME [TO]
    ALTER_RENAME = 1ULL << 5,

    /// Set for ORDER BY
    ALTER_ORDER = 1ULL << 6,

    /// Set for table_options
    ALTER_OPTIONS = 1ULL << 7,

    /// Set for ALTER [COLUMN] ... SET DEFAULT ... | DROP DEFAULT
    ALTER_CHANGE_COLUMN_DEFAULT = 1ULL << 8,

    /// Set for DISABLE KEYS | ENABLE KEYS
    ALTER_KEYS_ONOFF = 1ULL << 9,

    /// Set for FORCE
    /// Set for ENGINE(same engine)
    /// Set by mysql_recreate_table()
    ALTER_RECREATE = 1ULL << 10,

    /// Set for ADD PARTITION
    ALTER_ADD_PARTITION = 1ULL << 11,

    /// Set for DROP PARTITION
    ALTER_DROP_PARTITION = 1ULL << 12,

    /// Set for COALESCE PARTITION
    ALTER_COALESCE_PARTITION = 1ULL << 13,
    /// Set for REORGANIZE PARTITION ... INTO
    ALTER_REORGANIZE_PARTITION = 1ULL << 14,

    /// Set for partition_options
    ALTER_PARTITION = 1ULL << 15,

    /// Set for LOAD INDEX INTO CACHE ... PARTITION
    /// Set for CACHE INDEX ... PARTITION
    ALTER_ADMIN_PARTITION = 1ULL << 16,

    /// Set for REORGANIZE PARTITION
    ALTER_TABLE_REORG = 1ULL << 17,

    /// Set for REBUILD PARTITION
    ALTER_REBUILD_PARTITION = 1ULL << 18,

    /// Set for partitioning operations specifying ALL keyword
    ALTER_ALL_PARTITION = 1ULL << 19,

    /// Set for REMOVE PARTITIONING
    ALTER_REMOVE_PARTITIONING = 1ULL << 20,

    /// Set for ADD FOREIGN KEY
    ADD_FOREIGN_KEY = 1ULL << 21,

    /// Set for DROP FOREIGN KEY
    DROP_FOREIGN_KEY = 1ULL << 22,

    /// Set for EXCHANGE PARITION
    ALTER_EXCHANGE_PARTITION = 1ULL << 23,

    /// Set by Sql_cmd_alter_table_truncate_partition::execute()
    ALTER_TRUNCATE_PARTITION = 1ULL << 24,

    /// Set for ADD [COLUMN] FIRST | AFTER
    ALTER_COLUMN_ORDER = 1ULL << 25,

    /// Set for RENAME INDEX
    ALTER_RENAME_INDEX = 1ULL << 26,

    /// Set for discarding the tablespace
    ALTER_DISCARD_TABLESPACE = 1ULL << 27,

    /// Set for importing the tablespace
    ALTER_IMPORT_TABLESPACE = 1ULL << 28,

    /// Means that the visibility of an index is changed.
    ALTER_INDEX_VISIBILITY = 1ULL << 29,

    /// Set for SECONDARY LOAD
    ALTER_SECONDARY_LOAD = 1ULL << 30,    
    /// Set for SECONDARY UNLOAD
    ALTER_SECONDARY_UNLOAD = 1ULL << 31,

    /// Set for add check constraint.
    ADD_CHECK_CONSTRAINT = 1ULL << 32,

    /// Set for drop check constraint.
    DROP_CHECK_CONSTRAINT = 1ULL << 33,

    /// Set for check constraint enforce.
    ENFORCE_CHECK_CONSTRAINT = 1ULL << 34,

    /// Set for check constraint suspend.
    SUSPEND_CHECK_CONSTRAINT = 1ULL << 35,
  };
```