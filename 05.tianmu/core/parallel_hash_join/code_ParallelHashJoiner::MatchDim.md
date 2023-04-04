#1.ParallelHashJoiner::MatchDim

```
ParallelHashJoiner::MatchDim
--rows_count = mind->NumOfTuples(matched_dims_);
--CreateMatchingTasks(mit, rows_count, &task_iterators, &splitting_type);
--availabled_packs = (int)((rows_count + (1 << pack_power_) - 1) >> pack_power_);
--TempTablePackLocker temptable_pack_locker(vc2_, cond_hashed_, availabled_packs);
--std::vector<MatchTaskParams> match_task_params;
  match_task_params.reserve(task_iterators.size());
  int64_t matched_rows = 0;
--if (task_iterators.size() > 1) {
----//-
--else if (task_iterators.size() == 1) {
----auto &params = match_task_params.emplace_back();
    ftht.GetColumnEncoder(&params.column_bin_encoder);
    params.build_item = multi_index_builder_->CreateBuildItem();
    params.task_miter = *task_iterators.begin();
    matched_rows = AsyncMatchDim(&params);
--for (auto &params : match_task_params) {
----multi_index_builder_->AddBuildItem(params.build_item);
--for (int index = 0; index < cond_hashed_; ++index) {
    vc2_[index]->UnlockSourcePacks();
  }
--for (auto &j : other_cond_) j.UnlockSourcePacks();
--return matched_rows;
```