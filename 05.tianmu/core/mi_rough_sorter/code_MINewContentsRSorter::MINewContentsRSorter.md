#1.MINewContentsRSorter::MINewContentsRSorter

```
MINewContentsRSorter::MINewContentsRSorter
--worker = new MINewContentsRSorterWorker(bound_queue_size, this);
--tcomp = new IndexTable *[no_dim];  // these table should be compared (more
                                     // than one pack, potentially)
  tsort = new IndexTable *[no_dim];
  tall = new IndexTable *[no_dim];  // all tables
  tcheck = new bool[no_dim];        // these dimensions should be checked for pack numbers
--for (int dim = 0; dim < no_dim; dim++) {
    tall[dim] = nullptr;  // will remain nullptr if the dimension is not covered by sorter
    AddColumn(t_new[dim], dim);
--last_pack = new int[no_dim];
  block_size = (int64_t(1)) << min_block_shift;
```