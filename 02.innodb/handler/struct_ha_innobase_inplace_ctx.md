#1.struct ha_innobase_inplace_ctx

```cpp
struct ha_innobase_inplace_ctx : public inplace_alter_handler_ctx {
  /** Dummy query graph */
  que_thr_t *thr;
  /** The prebuilt struct of the creating instance */
  row_prebuilt_t *prebuilt;
  /** InnoDB indexes being created */
  dict_index_t **add_index;
  /** MySQL key numbers for the InnoDB indexes that are being created */
  const ulint *add_key_numbers;
  /** number of InnoDB indexes being created */
  ulint num_to_add_index;
  /** InnoDB indexes being dropped */
  dict_index_t **drop_index;
  /** number of InnoDB indexes being dropped */
  const ulint num_to_drop_index;
  /** InnoDB indexes being renamed */
  dict_index_t **rename;
  /** number of InnoDB indexes being renamed */
  const ulint num_to_rename;
  /** InnoDB foreign key constraints being dropped */
  dict_foreign_t **drop_fk;
  /** number of InnoDB foreign key constraints being dropped */
  const ulint num_to_drop_fk;
  /** InnoDB foreign key constraints being added */
  dict_foreign_t **add_fk;
  /** number of InnoDB foreign key constraints being dropped */
  const ulint num_to_add_fk;
  /** whether to create the indexes online */
  bool online;
  /** memory heap */
  mem_heap_t *heap;
  /** dictionary transaction */
  trx_t *trx;
  /** original table (if rebuilt, differs from indexed_table) */
  dict_table_t *old_table;
  /** table where the indexes are being created or dropped */
  dict_table_t *new_table;
  /** mapping of old column numbers to new ones, or NULL */
  const ulint *col_map;
  /** new column names, or NULL if nothing was renamed */
  const char **col_names;
  /** added AUTO_INCREMENT column position, or ULINT_UNDEFINED */
  const ulint add_autoinc;
  /** default values of ADD COLUMN, or NULL */
  const dtuple_t *add_cols;
  /** autoinc sequence to use */
  ib_sequence_t sequence;
  /** maximum auto-increment value */
  ulonglong max_autoinc;
  /** temporary table name to use for old table when renaming tables */
  const char *tmp_name;
  /** whether the order of the clustered index is unchanged */
  bool skip_pk_sort;
  /** virtual columns to be added */
  dict_v_col_t *add_vcol;
  const char **add_vcol_name;
  /** virtual columns to be dropped */
  dict_v_col_t *drop_vcol;
  const char **drop_vcol_name;
  /** ALTER TABLE stage progress recorder */
  ut_stage_alter_t *m_stage;
  /** FTS AUX Tables to drop */
  aux_name_vec_t *fts_drop_aux_vec;
};    

```