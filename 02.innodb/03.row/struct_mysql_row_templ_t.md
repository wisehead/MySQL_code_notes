#1.mysql_row_templ_t

```cpp
/* A struct describing a place for an individual column in the MySQL
row format which is presented to the table handler in ha_innobase.
This template struct is used to speed up row transformations between
Innobase and MySQL. */

struct mysql_row_templ_t {
    ulint   col_no;         /*!< column number of the column */
    ulint   rec_field_no;       /*!< field number of the column in an
                    Innobase record in the current index;
                    not defined if template_type is
                    ROW_MYSQL_WHOLE_ROW */
    ulint   clust_rec_field_no; /*!< field number of the column in an
                    Innobase record in the clustered index;
                    not defined if template_type is
                    ROW_MYSQL_WHOLE_ROW */
    ulint   icp_rec_field_no;   /*!< field number of the column in an
                    Innobase record in the current index;
                    not defined unless
                    index condition pushdown is used */
    ulint   mysql_col_offset;   /*!< offset of the column in the MySQL
                    row format */
    ulint   mysql_col_len;      /*!< length of the column in the MySQL
                    row format */
    ulint   mysql_null_byte_offset; /*!< MySQL NULL bit byte offset in a
                    MySQL record */
    ulint   mysql_null_bit_mask;    /*!< bit mask to get the NULL bit,
                    zero if column cannot be NULL */
    ulint   type;           /*!< column type in Innobase mtype
                    numbers DATA_CHAR... */
    ulint   mysql_type;     /*!< MySQL type code; this is always
                    < 256 */
    ulint   mysql_length_bytes; /*!< if mysql_type
                    == DATA_MYSQL_TRUE_VARCHAR, this tells
                    whether we should use 1 or 2 bytes to
                    store the MySQL true VARCHAR data
                    length at the start of row in the MySQL
                    format (NOTE that the MySQL key value
                    format always uses 2 bytes for the data
                    len) */
    ulint   charset;        /*!< MySQL charset-collation code
                    of the column, or zero */
    ulint   mbminlen;       /*!< minimum length of a char, in bytes,
                    or zero if not a char type */
    ulint   mbmaxlen;       /*!< maximum length of a char, in bytes,
                    or zero if not a char type */
    ulint   is_unsigned;        /*!< if a column type is an integer
                    type and this field is != 0, then
                    it is an unsigned integer type */
};

```