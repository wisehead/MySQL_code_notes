#1.ParallelHashJoiner::TraverseDim

```
ParallelHashJoiner::TraverseDim
--rows_count = mind->NumOfTuples(traversed_dims_);
--slice_capability = mit.GetSliceCapability();
--if (slice_capability.type == MIIterator::SliceCapability::Type::kFixed) {
----//--
--else if ((slice_capability.type == MIIterator::SliceCapability::Type::kLinear) &&(availabled_packs > kTraversedPacksPerFragment * 2)) {
----int64_t origin_size = rows_count;
----for (int index = 0; index < mind->NumOfDimensions(); index++) {
------if (traversed_dims_[index]) {
--------origin_size = std::max<int64_t>(origin_size, mind->OrigSize(index));
----packs_count = (int)((origin_size + (1 << pack_power_) - 1) >> pack_power_);
----split_count = EvaluateTraversedFragments(packs_count);
----packs_per_fragment = packs_count / split_count;
----int64_t rows_length = origin_size / split_count;
----for (int index = 0; index < split_count; ++index) {
------int packs_started = index * packs_per_fragment;
------packs_increased = (index == split_count - 1) ? (-1 - packs_started) : (packs_per_fragment - 1);
------MITaskIterator *iter = new MILinearPackTaskIterator(pack_power_, mind, traversed_dims_, index, split_count,
                                                          rows_length, packs_started, packs_started + packs_increased);
------task_iterators.push_back(iter);
--else
----MITaskIterator *iter = new MITaskIterator(mind, traversed_dims_, 0, 1, rows_count);
----task_iterators.push_back(iter);
--traversed_fragment_count = (int)task_iterators.size();
--tianmu_control_.lock(m_conn->GetThreadID()) << "Begin traversed with " << traversed_fragment_count << " threads with "
                                              << splitting_type << " type." << system::unlock;
--std::vector<TraverseTaskParams> traverse_task_params;
  traverse_task_params.reserve(task_iterators.size());
  traversed_hash_tables_.reserve(task_iterators.size());
--TempTablePackLocker temptable_pack_locker(vc1_, cond_hashed_, availabled_packs);
--for (MITaskIterator *iter : task_iterators) 
----traversed_hash_tables_.emplace_back(hash_table_key_size_, hash_table_tuple_size_,
                                                     iter->GetRowsLength(), pack_power_, watch_traversed_);
----ht.AssignColumnEncoder(column_bin_encoder_);
----ht.AssignColumnEncoder(column_bin_encoder_);
----auto &params = traverse_task_params.emplace_back();
----params.traversed_hash_table = &ht;
----params.build_item = multi_index_builder_->CreateBuildItem();
----params.task_miter = iter;
----res.insert(ha_tianmu_engine_->query_thread_pool.add_task(&ParallelHashJoiner::AsyncTraverseDim, this, &params));  
--for (size_t i = 0; i < res.size(); i++) 
----traversed_rows += res.get(i);//等待异步线程完成任务 
--for (auto &params : traverse_task_params) {
    if (params.too_many_conflicts && !tianmu_sysvar_join_disable_switch_side) {
      if (!force_switching_sides_ && !too_many_conflicts_)
        too_many_conflicts_ = true;
----if (params.no_space_left)
------//-
----multi_index_builder_->AddBuildItem(params.build_item);    
--for (int index = 0; index < cond_hashed_; ++index) {
----vc1_[index]->UnlockSourcePacks();                                             
```