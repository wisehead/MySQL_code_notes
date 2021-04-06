#1.struct HASH_LINK

```cpp
typedef struct st_hash_info {
  uint next;                                    /* index to next key */
  uchar *data;                                  /* data for current entry */
} HASH_LINK;
```