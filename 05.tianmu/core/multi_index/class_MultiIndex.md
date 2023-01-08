#1.class MultiIndex

```cpp
class MultiIndex {
 public:
  Transaction *m_conn;

  friend class MINewContents;
  friend class MIIterator;

  friend class MultiIndexBuilder;

private:

  int no_dimensions;
  int64_t *dim_size;   // the size of a dimension
  uint64_t no_tuples;  // actual number of tuples (also in case of virtual
                       // index); should be updated in any change of index
  uint32_t p_power;
  bool no_tuples_too_big;             // this flag is set if a virtual number of tuples
                                      // exceeds 2^64
  std::vector<bool> can_be_distinct;  // true if the dimension contain only one copy of
                                      // original rows, false if we cannot guarantee this
  std::vector<bool> used_in_output;   // true if given dimension is used for
                                      // generation of output columns

  std::vector<DimensionGroup *> dim_groups;  // all active dimension groups
  DimensionGroup **group_for_dim;            // pointers to elements of dim_groups, for
                                             // faster dimension identification
  int *group_num_for_dim;                    // an element number of dim_groups, for faster
                                             // dimension identification


  int iterator_lock;        // 0 - unlocked, >0 - normal iterator exists, -1 -
                            // updating iterator exists
  bool shallow_dim_groups;  // Indicates whether dim_groups is a shallow copy
};

```