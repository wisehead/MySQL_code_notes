#1.Type flags of an index

```cpp
/** Type flags of an index: OR'ing of the flags is allowed to define a
combination of types */
/* @{ */
#define DICT_CLUSTERED  1   /*!< clustered index */
#define DICT_UNIQUE 2   /*!< unique index */
#define DICT_UNIVERSAL  4   /*!< index which can contain records from any
                other index */
#define DICT_IBUF   8   /*!< insert buffer tree */
#define DICT_CORRUPT    16  /*!< bit to store the corrupted flag
                in SYS_INDEXES.TYPE */
#define DICT_FTS    32  /* FTS index; can't be combined with the
                other flags */

#define DICT_IT_BITS    6   /*!< number of bits used for
                SYS_INDEXES.TYPE */
/* @} */
```