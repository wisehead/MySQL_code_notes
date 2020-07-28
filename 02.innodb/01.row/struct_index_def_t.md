#1.struct index_def_t

```cpp
/** Definition of an index being created */
struct index_def_t {
  const char *name;          /*!< index name */
  bool rebuild;              /*!< whether the table is rebuilt */
  ulint ind_type;            /*!< 0, DICT_UNIQUE,
                             or DICT_CLUSTERED */
  ulint key_number;          /*!< MySQL key number,
                             or ULINT_UNDEFINED if none */
  ulint n_fields;            /*!< number of fields in index */
  index_field_t *fields;     /*!< field definitions */
  st_mysql_ftparser *parser; /*!< fulltext parser plugin */
  bool is_ngram;             /*!< true if it's ngram parser */
  bool srid_is_valid;        /*!< true if we want to check SRID
                             while inserting to index */
  uint32_t srid;             /*!< SRID obtained from dd column */
};

```