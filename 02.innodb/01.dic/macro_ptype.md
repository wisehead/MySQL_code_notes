#1.MACRO of ptype of dict_col_t

```cpp
/*-------------------------------------------*/
/* The 'PRECISE TYPE' of a column */
/*
Tables created by a MySQL user have the following convention:

- In the least significant byte in the precise type we store the MySQL type
code (not applicable for system columns).

- In the second least significant byte we OR flags DATA_NOT_NULL,
DATA_UNSIGNED, DATA_BINARY_TYPE.

- In the third least significant byte of the precise type of string types we
store the MySQL charset-collation code. In DATA_BLOB columns created with
< 4.0.14 we do not actually know if it is a BLOB or a TEXT column. Since there
are no indexes on prefixes of BLOB or TEXT columns in < 4.0.14, this is no
problem, though.

Note that versions < 4.1.2 or < 5.0.1 did not store the charset code to the
precise type, since the charset was always the default charset of the MySQL
installation. If the stored charset code is 0 in the system table SYS_COLUMNS
of InnoDB, that means that the default charset of this MySQL installation
should be used.

When loading a table definition from the system tables to the InnoDB data
dictionary cache in main memory, InnoDB versions >= 4.1.2 and >= 5.0.1 check
if the stored charset-collation is 0, and if that is the case and the type is
a non-binary string, replace that 0 by the default charset-collation code of
this MySQL installation. In short, in old tables, the charset-collation code
in the system tables on disk can be 0, but in in-memory data structures
(dtype_t), the charset-collation code is always != 0 for non-binary string
types.

In new tables, in binary string types, the charset-collation code is the
MySQL code for the 'binary charset', that is, != 0.

For binary string types and for DATA_CHAR, DATA_VARCHAR, and for those
DATA_BLOB which are binary or have the charset-collation latin1_swedish_ci,
InnoDB performs all comparisons internally, without resorting to the MySQL
comparison functions. This is to save CPU time.

InnoDB's own internal system tables have different precise types for their
columns, and for them the precise type is usually not used at all.
*/

#define DATA_ENGLISH    4   /* English language character string: this
                is a relic from pre-MySQL time and only used
                for InnoDB's own system tables */
#define DATA_ERROR  111 /* another relic from pre-MySQL time */

#define DATA_MYSQL_TYPE_MASK 255 /* AND with this mask to extract the MySQL
                 type from the precise type */
#define DATA_MYSQL_TRUE_VARCHAR 15 /* MySQL type code for the >= 5.0.3
                   format true VARCHAR */

/* Precise data types for system columns and the length of those columns;
NOTE: the values must run from 0 up in the order given! All codes must
be less than 256 */
#define DATA_ROW_ID 0   /* row id: a 48-bit integer */
#define DATA_ROW_ID_LEN 6   /* stored length for row id */

#define DATA_TRX_ID 1   /* transaction id: 6 bytes */
#define DATA_TRX_ID_LEN 6

#define DATA_ROLL_PTR   2   /* rollback data pointer: 7 bytes */
#define DATA_ROLL_PTR_LEN 7

#define DATA_N_SYS_COLS 3   /* number of system columns defined above */

#define DATA_FTS_DOC_ID 3   /* Used as FTS DOC ID column */

#define DATA_SYS_PRTYPE_MASK 0xF /* mask to extract the above from prtype */

/* Flags ORed to the precise data type */
#define DATA_NOT_NULL   256 /* this is ORed to the precise type when
                the column is declared as NOT NULL */
#define DATA_UNSIGNED   512 /* this id ORed to the precise type when
                we have an unsigned integer type */
#define DATA_BINARY_TYPE 1024   /* if the data type is a binary character
                string, this is ORed to the precise type:
                this only holds for tables created with
                >= MySQL-4.0.14 */
/* #define  DATA_NONLATIN1  2048 This is a relic from < 4.1.2 and < 5.0.1.
                In earlier versions this was set for some
                BLOB columns.
*/
#define DATA_LONG_TRUE_VARCHAR 4096 /* this is ORed to the precise data
                type when the column is true VARCHAR where
                MySQL uses 2 bytes to store the data len;
                for shorter VARCHARs MySQL uses only 1 byte */
/*-------------------------------------------*/

/* This many bytes we need to store the type information affecting the
alphabetical order for a single field and decide the storage size of an
SQL null*/
#define DATA_ORDER_NULL_TYPE_BUF_SIZE       4
/* In the >= 4.1.x storage format we add 2 bytes more so that we can also
store the charset-collation number; one byte is left unused, though */
#define DATA_NEW_ORDER_NULL_TYPE_BUF_SIZE   6

/* Maximum multi-byte character length in bytes, plus 1 */
#define DATA_MBMAX  5

/* Pack mbminlen, mbmaxlen to mbminmaxlen. */
#define DATA_MBMINMAXLEN(mbminlen, mbmaxlen)    \
    ((mbmaxlen) * DATA_MBMAX + (mbminlen))
/* Get mbminlen from mbminmaxlen. Cast the result of UNIV_EXPECT to ulint
because in GCC it returns a long. */
#define DATA_MBMINLEN(mbminmaxlen) ((ulint) \
                                    UNIV_EXPECT(((mbminmaxlen) % DATA_MBMAX), \
                                                1))
/* Get mbmaxlen from mbminmaxlen. */
#define DATA_MBMAXLEN(mbminmaxlen) ((ulint) ((mbminmaxlen) / DATA_MBMAX))

/* We now support 15 bits (up to 32767) collation number */
#define MAX_CHAR_COLL_NUM   32767

/* Mask to get the Charset Collation number (0x7fff) */
#define CHAR_COLL_MASK      MAX_CHAR_COLL_NUM
```