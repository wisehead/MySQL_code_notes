#1.class MIIterator

```cpp
/*! \brief Used for iteration on chosen dimensions in a MultiIndex.
 * Usage example:
 * MIIterator it(mind,...);
 * it.Rewind();
 * while(it.IsValid()) {
 *   ...
 *   ++it;
 * }
 *
 */
class MIIterator {
 public:
  // The splitting capability supported by MIIterator.
  struct SliceCapability {
    enum class Type {
      kDisable = 0,  // Disable splitting into block.
      kLinear,       // Splitting into block with pack or line, the internal iterator
                     // is FilterOnesIterator.
      kFixed         // Splitting into block with a fixed value,
                     // the internal iterator is
                     // DimensionGroupMultiMaterialized::DGIterator.
    };
    Type type = Type::kDisable;
    std::vector<int64_t> slices;  // Every element is slice size.
  };
 protected:
  void GeneralIncrement();  // a general-case part of operator++

  std::vector<DimensionGroup::Iterator *> it;  // iterators created for the groups
  std::vector<DimensionGroup *> dg;            // external pointer: dimension groups to be iterated
  int *it_for_dim;                             // iterator no. for given dimensions

  MultiIndex *mind;           // a multiindex the iterator is created for
  bool mind_created_locally;  // true, if the multiindex should be deleted in
                              // descructor
  int no_dims;                // number of dimensions in the associated multiindex
  DimensionVector dimensions;

  int64_t *cur_pos;  // a buffer storing the current position
  int *cur_pack;     // a buffer storing the current pack number
  bool valid;        // false if we are already out of multiindex

  int64_t omitted_factor;  // how many tuples in omitted dimensions are skipped
                           // at each iterator step
  // common::NULL_VALUE_64 means more than 2^63
  int64_t no_obj;    // how many steps (tuples) will the iterator perform
  uint32_t p_power;  // 2^p_power per pack max number
  // common::NULL_VALUE_64 means more than 2^63
  int64_t pack_size_left;  // how many steps (tuples) will the iterator
  // perform inside the current packrow, incl. the current one
  bool next_pack_started;  // true if the current row is the first one inside
                           // the packrow
  MIIteratorType mii_type;
  std::vector<PackOrderer> &po;  // for ordered iterator

  // Optimized part

  int one_filter_dim;                       // if there is only one filter to be iterated, this is
                                            // its number, otherwise -1
  DimensionGroup::Iterator *one_filter_it;  // external pointer: the iterator
                                            // connected to the one dim, if any
  int TaskId;                               // for multithread
  int TasksNum;                             // for multithread


```