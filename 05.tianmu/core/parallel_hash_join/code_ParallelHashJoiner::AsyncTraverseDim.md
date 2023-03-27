#1.ParallelHashJoiner::AsyncTraverseDim

```
ParallelHashJoiner::AsyncTraverseDim
--params->traversed_hash_table->Initialize();
--HashTable *hash_table = params->traversed_hash_table->hash_table();
--MIIterator &miter(*params->task_miter->GetIter());
--while (params->task_miter->IsValid()) {
----if (miter.PackrowStarted()) {
------for (int index = 0; index < cond_hashed_; ++index) vc1_[index]->LockSourcePacks(miter);
----for (int index = 0; index < cond_hashed_; index++) {
------if (vc1_[index]->IsNull(miter)) {
--------SingleColumn::IsNullImpl
----------TianmuAttr::IsNull
----------col_->IsNull(mit[dim_]);
--------omit_this_row = true;
        break;
------ColumnBinEncoder *column_bin_encoder = params->traversed_hash_table->GetColumnEncoder(index);
------ColumnBinEncoder::Encode        
```