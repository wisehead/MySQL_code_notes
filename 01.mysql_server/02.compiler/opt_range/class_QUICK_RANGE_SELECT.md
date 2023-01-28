#1.class QUICK_RANGE_SELECT

```cpp
/*
  Quick select that does a range scan on a single key. The records are
  returned in key order if ::need_sorted_output() has been called.
*/

class QUICK_RANGE_SELECT : public QUICK_SELECT_I
{
protected:
  handler *file;
  /* Members to deal with case when this quick select is a ROR-merged scan */
  bool in_ror_merged_scan;
  MY_BITMAP column_bitmap;

  friend class TRP_ROR_INTERSECT;
  friend
  QUICK_RANGE_SELECT *get_quick_select_for_ref(THD *thd, TABLE *table,
                                               struct st_table_ref *ref,
                                               ha_rows records);
  friend bool get_quick_keys(PARAM *param,
                             QUICK_RANGE_SELECT *quick,KEY_PART *key,
                             SEL_ARG *key_tree,
                             uchar *min_key, uint min_key_flag,
                             uchar *max_key, uint max_key_flag);
  friend QUICK_RANGE_SELECT *get_quick_select(PARAM*,uint idx,
                                              SEL_ARG *key_tree,
                                              uint mrr_flags,
                                              uint mrr_buf_size,
                                              MEM_ROOT *alloc);
  friend uint quick_range_seq_next(range_seq_t rseq, KEY_MULTI_RANGE *range);
  friend range_seq_t quick_range_seq_init(void *init_param,
                                          uint n_ranges, uint flags);
  friend class QUICK_SELECT_DESC;
  friend class QUICK_INDEX_MERGE_SELECT;
  friend class QUICK_ROR_INTERSECT_SELECT;
  friend class QUICK_GROUP_MIN_MAX_SELECT;

  DYNAMIC_ARRAY ranges;     /* ordered array of range ptrs */
  bool free_file;   /* TRUE <=> this->file is "owned" by this quick select */

  /* Range pointers to be used when not using MRR interface */
  QUICK_RANGE **cur_range;  /* current element in ranges  */
  QUICK_RANGE *last_range;
  
  /* Members needed to use the MRR interface */
  QUICK_RANGE_SEQ_CTX qr_traversal_ctx;
public:
  uint mrr_flags; /* Flags to be used with MRR interface */
protected:
  uint mrr_buf_size; /* copy from thd->variables.read_rnd_buff_size */  
  HANDLER_BUFFER *mrr_buf_desc; /* the handler buffer */

  /* Info about index we're scanning */
  KEY_PART *key_parts;
  KEY_PART_INFO *key_part_info;
  
  bool dont_free; /* Used by QUICK_SELECT_DESC */

  int cmp_next(QUICK_RANGE *range);
  int cmp_prev(QUICK_RANGE *range);
  bool row_in_ranges();
public:
  MEM_ROOT alloc;

  QUICK_RANGE_SELECT(THD *thd, TABLE *table,uint index_arg,bool no_alloc,
                     MEM_ROOT *parent_alloc, bool *create_error);
  ~QUICK_RANGE_SELECT();
  
  void need_sorted_output();
  int init();
  int reset(void);
  int get_next();
  void range_end();
  int get_next_prefix(uint prefix_length, uint group_key_parts, 
                      uchar *cur_prefix);
  bool reverse_sorted() const { return false; }
  bool reverse_sort_possible() const { return true; }
  bool unique_key_range();
  int init_ror_merged_scan(bool reuse_handler);
  void save_last_pos()
  { file->position(record); }
  int get_type() { return QS_TYPE_RANGE; }
  void add_keys_and_lengths(String *key_names, String *used_lengths);
  void add_info_string(String *str);
#ifndef DBUG_OFF
  void dbug_dump(int indent, bool verbose);
#endif
  QUICK_SELECT_I *make_reverse(uint used_key_parts_arg);
  void set_handler(handler *file_arg) { file= file_arg; }
private:
  /* Default copy ctor used by QUICK_SELECT_DESC */
};
```