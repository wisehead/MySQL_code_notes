#1.struct Query_cache_block

```cpp
struct Query_cache_block
{
  Query_cache_block() {}                      /* Remove gcc warning */
  enum block_type {FREE, QUERY, RESULT, RES_CONT, RES_BEG,
           RES_INCOMPLETE, TABLE, INCOMPLETE};

  ulong length;                 // length of all block
  ulong used;                   // length of data
  /*
    Not used **pprev, **prev because really needed access to pervious block:
    *pprev to join free blocks
    *prev to access to opposite side of list in cyclic sorted list
  */
  Query_cache_block *pnext,*pprev,      // physical next/previous block
            *next,*prev;        // logical next/previous block
  block_type type;
  TABLE_COUNTER_TYPE n_tables;          // number of tables in query
};


```