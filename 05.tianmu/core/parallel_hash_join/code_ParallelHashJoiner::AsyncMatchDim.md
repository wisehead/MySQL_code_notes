#1.ParallelHashJoiner::AsyncMatchDim

```
ParallelHashJoiner::AsyncMatchDim
--auto &ftht = traversed_hash_tables_[0];
  std::vector<ColumnBinEncoder> &column_bin_encoder(params->column_bin_encoder);
  std::string key_input_buffer(ftht.hash_table()->GetKeyBufferWidth(), 0);
  MIIterator &miter(*params->task_miter->GetIter());
--matching_row = params->task_miter->GetStartPackrows();
--MIDummyIterator combined_mit(mind);  // a combined iterator for checking non-hashed conditions, if any
--while (params->task_miter->IsValid() && !interrupt_matching_) {
----if (miter.PackrowStarted()) {
------for (int index = 0; index < cond_hashed_; ++index) {
--------if (column_bin_encoder[index].IsString()) {
----------if (!vc2_[index]->Type().Lookup()) { 
------------types::BString local_min = vc2_[index]->GetMinString(miter);
------------types::BString local_max = vc2_[index]->GetMaxString(miter);
------------packrow_uniform = false;
------packrows_matched_++;
------if (packrow_uniform && !omit_this_packrow) {
--------//-
------for (int i = 0; i < cond_hashed_; i++) vc2_[i]->LockSourcePacks(miter);
----for (int index = 0; index < cond_hashed_; ++index) {
------if (vc2_[index]->IsNull(miter)) {
--------//-
------column_bin_encoder[index].Encode(reinterpret_cast<unsigned char *>(key_input_buffer.data()), miter, vc2_[index]);
--------ColumnBinEncoder::Encode
----------my_encoder->Encode(buf + val_offset, buf + val_sec_offset, (alternative_vc ? alternative_vc : vc), mit, update_stats);
------------ColumnBinEncoder::EncoderText_UTF::Encode
----if (!null_found && !non_matching_sizes) {
------for (auto &traversed_hash_table : traversed_hash_tables_) {
--------HashTable *hash_table = traversed_hash_table.hash_table();
--------HashTable::Finder hash_table_finder(hash_table, &key_input_buffer);
--------int64_t matching_rows = hash_table_finder.GetMatchedRows();
--------if (!other_cond_exist_) {
----------if (!tips.count_only)
------------while ((hash_row = hash_table_finder.GetNextRow()) != common::NULL_VALUE_64)
--------------SubmitJoinedTuple(params->build_item.get(), &traversed_hash_table, hash_row, miter);
```