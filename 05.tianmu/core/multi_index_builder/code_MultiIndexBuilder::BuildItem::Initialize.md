#1.MultiIndexBuilder::BuildItem::Initialize

```
MultiIndexBuilder::BuildItem::Initialize
--MultiIndex *mind = builder_->multi_index_;
--for (int dim = 0; dim < builder_->dims_count_; ++dim) {
----nulls_possible_[dim] = false;
----index_table_[dim] = nullptr;
----if (builder_->dims_involved_[dim]) {
      if (builder_->forget_now_[dim])
        continue;
------index_table_[dim] = new IndexTable(initial_size, mind->OrigSize(dim), 0);
      index_table_[dim]->SetNumOfLocks(mind->group_for_dim[dim]->NumOfLocks(dim));
      min_block_shift = std::min(min_block_shift, index_table_[dim]->BlockShift());

      if (initial_size > (1U << mind->ValueOfPower()))
        rough_sort_needed = true;
--if (rough_sort_needed)
    rough_sorter_.reset(new MINewContentsRSorter(mind, index_table_, min_block_shift));                
```