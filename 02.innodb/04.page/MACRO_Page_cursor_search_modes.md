#1.Macro Page cursor search modes

```cpp
/* Page cursor search modes; the values must be in this order! */
 
#define PAGE_CUR_UNSUPP 0
#define PAGE_CUR_G  1
#define PAGE_CUR_GE 2                                                                                                                                                                                                                                           
#define PAGE_CUR_L  3
#define PAGE_CUR_LE 4
/*#define PAGE_CUR_LE_OR_EXTENDS 5*/ /* This is a search mode used in
                 "column LIKE 'abc%' ORDER BY column DESC";
                 we have to find strings which are <= 'abc' or
                 which extend it */
#ifdef UNIV_SEARCH_DEBUG
# define PAGE_CUR_DBG   6   /* As PAGE_CUR_LE, but skips search shortcut */
#endif /* UNIV_SEARCH_DEBUG */
```