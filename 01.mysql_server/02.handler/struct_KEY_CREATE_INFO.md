#1.struct KEY_CREATE_INFO

```cpp
typedef struct st_key_create_information
{
  enum ha_key_alg algorithm;
  ulong block_size;
  LEX_STRING parser_name;
  LEX_STRING comment;
  /**
    A flag to determine if we will check for duplicate indexes.
    This typically means that the key information was specified
    directly by the user (set by the parser) or a column
    associated with it was dropped.
  */
  bool check_for_duplicate_indexes;
} KEY_CREATE_INFO;
```