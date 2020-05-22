#1.MACRO of mtype of dict_col_t

```cpp
/*-------------------------------------------*/
/* The 'MAIN TYPE' of a column */
#define DATA_MISSING    0   /* missing column */
#define DATA_VARCHAR    1   /* character varying of the
                latin1_swedish_ci charset-collation; note
                that the MySQL format for this, DATA_BINARY,
                DATA_VARMYSQL, is also affected by whether the
                'precise type' contains
                DATA_MYSQL_TRUE_VARCHAR */
#define DATA_CHAR   2   /* fixed length character of the
                latin1_swedish_ci charset-collation */
#define DATA_FIXBINARY  3   /* binary string of fixed length */
#define DATA_BINARY 4   /* binary string */
#define DATA_BLOB   5   /* binary large object, or a TEXT type;
                if prtype & DATA_BINARY_TYPE == 0, then this is
                actually a TEXT column (or a BLOB created
                with < 4.0.14; since column prefix indexes
                came only in 4.0.14, the missing flag in BLOBs
                created before that does not cause any harm) */
#define DATA_INT    6   /* integer: can be any size 1 - 8 bytes */
#define DATA_SYS_CHILD  7   /* address of the child page in node pointer */
#define DATA_SYS    8   /* system column */

/* Data types >= DATA_FLOAT must be compared using the whole field, not as
binary strings */

#define DATA_FLOAT  9
#define DATA_DOUBLE 10
#define DATA_DECIMAL    11  /* decimal number stored as an ASCII string */
#define DATA_VARMYSQL   12  /* any charset varying length char */
#define DATA_MYSQL  13  /* any charset fixed length char */
                /* NOTE that 4.1.1 used DATA_MYSQL and
                DATA_VARMYSQL for all character sets, and the
                charset-collation for tables created with it
                can also be latin1_swedish_ci */
#define DATA_MTYPE_MAX  63  /* dtype_store_for_order_and_null_size()
                requires the values are <= 63 */
```