#1.struct st_hash

```cpp
typedef struct st_hash {
  size_t key_offset,key_length;     /* Length of key if const length */
  size_t blength;
  ulong records;
  uint flags;
  DYNAMIC_ARRAY array;              /* Place for hash_keys */
  my_hash_get_key get_key;
  void (*free)(void *);
  CHARSET_INFO *charset;
  my_hash_function hash_function;
  PSI_memory_key m_psi_key;
} HASH;

```