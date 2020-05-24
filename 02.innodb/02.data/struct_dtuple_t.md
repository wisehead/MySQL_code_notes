#1.dtuple_t

```cpp
/** Structure for an SQL data tuple of fields (logical record) */
struct dtuple_t {
    ulint       info_bits;  /*!< info bits of an index record:
                    the default is 0; this field is used
                    if an index record is built from
                    a data tuple */
    ulint       n_fields;   /*!< number of fields in dtuple */
    ulint       n_fields_cmp;   /*!< number of fields which should
                    be used in comparison services
                    of rem0cmp.*; the index search
                    is performed by comparing only these
                    fields, others are ignored; the
                    default value in dtuple creation is
                    the same value as n_fields */
    dfield_t*   fields;     /*!< fields */
    UT_LIST_NODE_T(dtuple_t) tuple_list;
                    /*!< data tuples can be linked into a
                    list using this field */
#ifdef UNIV_DEBUG
    ulint       magic_n;    /*!< magic number, used in
                    debug assertions */
/** Value of dtuple_t::magic_n */
# define        DATA_TUPLE_MAGIC_N  65478679
#endif /* UNIV_DEBUG */
};
```