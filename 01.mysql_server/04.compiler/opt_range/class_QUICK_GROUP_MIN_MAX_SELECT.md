#1.class QUICK_GROUP_MIN_MAX_SELECT

```cpp
/*
  Index scan for GROUP-BY queries with MIN/MAX aggregate functions.

  This class provides a specialized index access method for GROUP-BY queries
  of the forms:

       SELECT A_1,...,A_k, [B_1,...,B_m], [MIN(C)], [MAX(C)]
         FROM T
        WHERE [RNG(A_1,...,A_p ; where p <= k)]
         [AND EQ(B_1,...,B_m)]
         [AND PC(C)]
         [AND PA(A_i1,...,A_iq)]
       GROUP BY A_1,...,A_k;

    or

       SELECT DISTINCT A_i1,...,A_ik
         FROM T
        WHERE [RNG(A_1,...,A_p ; where p <= k)]
         [AND PA(A_i1,...,A_iq)];

  where all selected fields are parts of the same index.
  The class of queries that can be processed by this quick select is fully
  specified in the description of get_best_trp_group_min_max() in opt_range.cc.

  The get_next() method directly produces result tuples, thus obviating the
  need to call end_send_group() because all grouping is already done inside
  get_next().

  Since one of the requirements is that all select fields are part of the same
  index, this class produces only index keys, and not complete records.
*/

class QUICK_GROUP_MIN_MAX_SELECT : public QUICK_SELECT_I
{
private:
  JOIN *join;            /* Descriptor of the current query */
  KEY  *index_info;      /* The index chosen for data access */
  uchar *record;          /* Buffer where the next record is returned. */
  uchar *tmp_record;      /* Temporary storage for next_min(), next_max(). */
  uchar *group_prefix;    /* Key prefix consisting of the GROUP fields. */
  const uint group_prefix_len; /* Length of the group prefix. */
  uint group_key_parts;  /* A number of keyparts in the group prefix */
  uchar *last_prefix;     /* Prefix of the last group for detecting EOF. */
  bool have_min;         /* Specify whether we are computing */
  bool have_max;         /*   a MIN, a MAX, or both.         */
  bool have_agg_distinct;/*   aggregate_function(DISTINCT ...).  */
  bool seen_first_key;   /* Denotes whether the first key was retrieved.*/
  KEY_PART_INFO *min_max_arg_part; /* The keypart of the only argument field */
                                   /* of all MIN/MAX functions.              */
  uint min_max_arg_len;  /* The length of the MIN/MAX argument field */
  uchar *key_infix;       /* Infix of constants from equality predicates. */
  uint key_infix_len;
  DYNAMIC_ARRAY min_max_ranges; /* Array of range ptrs for the MIN/MAX field. */
  uint real_prefix_len; /* Length of key prefix extended with key_infix. */
  uint real_key_parts;  /* A number of keyparts in the above value.      */
  List<Item_sum> *min_functions;
  List<Item_sum> *max_functions;
  List_iterator<Item_sum> *min_functions_it;
  List_iterator<Item_sum> *max_functions_it;
  /* 
    Use index scan to get the next different key instead of jumping into it 
    through index read 
  */
  bool is_index_scan; 
public:
  /*
    The following two members are public to allow easy access from
    TRP_GROUP_MIN_MAX::make_quick()
  */
  MEM_ROOT alloc; /* Memory pool for this and quick_prefix_select data. */
  QUICK_RANGE_SELECT *quick_prefix_select;/* For retrieval of group prefixes. */
private:
  int  next_prefix();
  int  next_min_in_range();
  int  next_max_in_range();
  int  next_min();
  int  next_max();
  void update_min_result();
  void update_max_result();
public:
  QUICK_GROUP_MIN_MAX_SELECT(TABLE *table, JOIN *join, bool have_min,
                             bool have_max, bool have_agg_distinct,
                             KEY_PART_INFO *min_max_arg_part,
                             uint group_prefix_len, uint group_key_parts,
                             uint used_key_parts, KEY *index_info, uint
                             use_index, double read_cost, ha_rows records, uint
                             key_infix_len, uchar *key_infix, MEM_ROOT
                             *parent_alloc, bool is_index_scan);
  ~QUICK_GROUP_MIN_MAX_SELECT();
  bool add_range(SEL_ARG *sel_range);
  void update_key_stat();
  void adjust_prefix_ranges();
  bool alloc_buffers();
  int init();
  void need_sorted_output() { /* always do it */ }
  int reset();
  int get_next();
  bool reverse_sorted() const { return false; }
  bool reverse_sort_possible() const { return false; }
  bool unique_key_range() { return false; }
  int get_type() { return QS_TYPE_GROUP_MIN_MAX; }
  void add_keys_and_lengths(String *key_names, String *used_lengths);
#ifndef DBUG_OFF
  void dbug_dump(int indent, bool verbose);
#endif
  bool is_agg_distinct() { return have_agg_distinct; }
  virtual void append_loose_scan_type(String *str) 
  {
    if (is_index_scan)
      str->append(STRING_WITH_LEN("scanning"));
  }
};
```