#1 enum fil_type_t

```cpp
/** File types */
enum fil_type_t : uint8_t {
  /** temporary tablespace (temporary undo log or tables) */
  FIL_TYPE_TEMPORARY = 1,
  /** a tablespace that is being imported (no logging until finished) */
  FIL_TYPE_IMPORT = 2,
  /** persistent tablespace (for system, undo log or tables) */
  FIL_TYPE_TABLESPACE = 4,
  /** redo log covering changes to files of FIL_TYPE_TABLESPACE */
  FIL_TYPE_LOG = 8
};
```