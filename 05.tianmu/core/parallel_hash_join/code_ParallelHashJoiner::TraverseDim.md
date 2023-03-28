#1.ParallelHashJoiner::TraverseDim

```
ParallelHashJoiner::TraverseDim
--rows_count = mind->NumOfTuples(traversed_dims_);
--slice_capability = mit.GetSliceCapability();
--if (slice_capability.type == MIIterator::SliceCapability::Type::kFixed) {
----//--
--else if ((slice_capability.type == MIIterator::SliceCapability::Type::kLinear) &&(availabled_packs > kTraversedPacksPerFragment * 2)) {
----//--
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
```