#1.ParallelHashJoiner::CreateMatchingTasks

```
ParallelHashJoiner::CreateMatchingTasks
--slice_capability = mit.GetSliceCapability();
--if (slice_capability.type == MIIterator::SliceCapability::Type::kFixed) {
----//-
--else if (slice_capability.type == MIIterator::SliceCapability::Type::kLinear) 
----packs_count = (int)((rows_count + (1 << pack_power_) - 1) >> pack_power_);
----for (int index = 0; index < mind->NumOfDimensions(); index++) {
      if (matched_dims_[index]) {
        Filter *filter = mind->GetFilter(index);
        if (filter)
          packs_count = filter->NumOfBlocks();
----if (packs_count > kJoinSplittedMinPacks) {
------//-
----else if (tianmu_sysvar_join_splitrows > 0) {
------//-
----else {
------MITaskIterator *iter = new MITaskIterator(mind, matched_dims_, 0, 1, 0);
------task_iterators->push_back(iter);          
```