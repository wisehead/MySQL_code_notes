#1.struct MDL_key

```cpp
/**
  Metadata lock object key.

  A lock is requested or granted based on a fully qualified name and type.
  E.g. They key for a table consists of <0 (=table)>+<database>+<table name>.
  Elsewhere in the comments this triple will be referred to simply as "key"
  or "name".
*/

struct MDL_key
{
private:
  uint16 m_length;
  uint16 m_db_name_length;
  char m_ptr[MAX_MDLKEY_LENGTH];
  static PSI_stage_info m_namespace_to_wait_state_name[NAMESPACE_END];
};
```