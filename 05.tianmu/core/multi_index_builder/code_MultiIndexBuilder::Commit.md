#1.MultiIndexBuilder::Commit

```
MultiIndexBuilder::Commit
--std::vector<int> no_locks(dims_count_);
  for (int dim = 0; dim < dims_count_; dim++) {
    if (dims_involved_[dim]) {
      no_locks[dim] = multi_index_->group_for_dim[dim]->NumOfLocks(dim);
--for (int dim = 0; dim < dims_count_; dim++) {
    if (dims_involved_[dim]) {
      int group_no = multi_index_->group_num_for_dim[dim];
      if (multi_index_->dim_groups[group_no]) {  // otherwise already deleted
        delete multi_index_->dim_groups[group_no];
        multi_index_->dim_groups[group_no] = nullptr;      
--DimensionGroupMultiMaterialized *ng =
      new DimensionGroupMultiMaterialized(joined_tuples, dims_involved_, multi_index_->ValueOfPower());
--multi_index_->dim_groups.push_back(ng);
--for (auto &build_item : build_items_) {
----if (build_item->GetCount() > 0) {
------for (int dim = 0; dim < dims_count_; dim++) {
--------IndexTable *index_table = build_item->ReleaseIndexTable(dim);
--------if (dims_involved_[dim] && !forget_now_[dim]) {
----------index_table->SetNumOfLocks(no_locks[dim]);
----------ng->AddDimensionContent(dim, index_table, build_item->GetCount(), build_item->NullExisted(dim));
------------DimensionGroupMultiMaterialized::AddDimensionContent
--------------tables->AddTable(table, count, nulls);
--multi_index_->FillGroupForDim();
--multi_index_->UpdateNumOfTuples();
```