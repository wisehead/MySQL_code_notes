#1.LF_SLIST

```cpp
/* An element of the list */
typedef struct {
  intptr volatile link; /* a pointer to the next element in a listand a flag */
  uint32 hashnr;        /* reversed hash number, for sorting                 */
  const uchar *key;
  size_t keylen;
  /*
    data is stored here, directly after the keylen.
    thus the pointer to data is (void*)(slist_element_ptr+1)
  */
} LF_SLIST;
```