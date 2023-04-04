#1.MultiIndexBuilder::BuildItem::CommitTableValues

```
MultiIndexBuilder::BuildItem::CommitTableValues
--for (int dim = 0; dim < builder_->dims_count_; ++dim) {
----if (index_table_[dim]) {
------if ((uint64_t)added_count_ >= index_table_[dim]->N()) {
--------//-
------if (cached_values_[dim] == common::NULL_VALUE_64) {
--------//--
------else
--------index_table_[dim]->Set64(added_count_, cached_values_[dim] + 1);
--added_count_++;
```