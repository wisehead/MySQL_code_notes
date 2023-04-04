#1.ParallelHashJoiner::SubmitJoinedTuple

```
ParallelHashJoiner::SubmitJoinedTuple
--if (!outer_nulls_only_) {
----HashTable *hash_table = traversed_hash_table->hash_table();
----for (int index = 0; index < mind->NumOfDimensions(); ++index) {
------if (matched_dims_[index]) {
--------build_item->SetTableValue(index, mit[index]);
------} else if (traversed_dims_[index]) {
--------build_item->SetTableValue(index, hash_table->GetTupleValue(traversed_hash_column_[index], hash_row));
----build_item->CommitTableValues();

```