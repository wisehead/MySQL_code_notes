#1.enum TO_TYPE

```cpp
enum class TO_TYPE {
  TO_PACK = 0,
  TO_SORTER,
  TO_CACHEDBUFFER,
  TO_FILTER,
  TO_MULTIFILTER2,
  TO_INDEXTABLE,
  TO_RSINDEX,
  TO_TEMPORARY,
  TO_FTREE,
  TO_SPLICE,
  TO_INITIALIZER,
  TO_DEPENDENT,  // object is dependent from other one
  TO_REFERENCE,  // Logical reference to an object on disk
  TO_DATABLOCK
};
```