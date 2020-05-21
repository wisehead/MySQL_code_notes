#1.dtype_t

```cpp
/* Structure for an SQL data type.
If you add fields to this structure, be sure to initialize them everywhere.
This structure is initialized in the following functions:
dtype_set()
dtype_read_for_order_and_null_size()
dtype_new_read_for_order_and_null_size()
sym_tab_add_null_lit() */

struct dtype_t{
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
#ifndef UNIV_HOTBACKUP
    unsigned    mbminmaxlen:5;  /*!< minimum and maximum length of a
                    character, in bytes;
                    DATA_MBMINMAXLEN(mbminlen,mbmaxlen);
                    mbminlen=DATA_MBMINLEN(mbminmaxlen);
                    mbmaxlen=DATA_MBMINLEN(mbminmaxlen) */
#endif /* !UNIV_HOTBACKUP */
};
```