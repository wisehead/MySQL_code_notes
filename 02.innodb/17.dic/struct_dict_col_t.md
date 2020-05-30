#1.dict_col_t

```cpp
/** Data structure for a column in a table */
struct dict_col_t{
    /*----------------------*/
    /** The following are copied from dtype_t,
    so that all bit-fields can be packed tightly. */
    /* @{ */
    unsigned    prtype:32;  /*!< precise type; MySQL data
                    type, charset code, flags to
                    indicate nullability,
                    signedness, whether this is a
                    binary string, whether this is
                    a true VARCHAR where MySQL
                    uses 2 bytes to store the length */
    unsigned    mtype:8;    /*!< main data type */

    /* the remaining fields do not affect alphabetical ordering: */

    unsigned    len:16;     /*!< length; for MySQL data this
                    is field->pack_length(),
                    except that for a >= 5.0.3
                    type true VARCHAR this is the
                    maximum byte length of the
                    string data (in addition to
                    the string, MySQL uses 1 or 2
                    bytes to store the string length) */

    unsigned    mbminmaxlen:5;  /*!< minimum and maximum length of a
                    character, in bytes;
                    DATA_MBMINMAXLEN(mbminlen,mbmaxlen);
                    mbminlen=DATA_MBMINLEN(mbminmaxlen);
                    mbmaxlen=DATA_MBMINLEN(mbminmaxlen) */
    /*----------------------*/
    /* End of definitions copied from dtype_t */
    /* @} */

    unsigned    ind:10;     /*!< table column position
                    (starting from 0) */
    unsigned    ord_part:1; /*!< nonzero if this column
                    appears in the ordering fields
                    of an index */
    unsigned    max_prefix:12;  /*!< maximum index prefix length on
                    this column. Our current max limit is
                    3072 for Barracuda table */
};
```