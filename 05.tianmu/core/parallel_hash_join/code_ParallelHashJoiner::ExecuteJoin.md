#1.ParallelHashJoiner::ExecuteJoin

```
ParallelHashJoiner::ExecuteJoin
--MIIterator traversed_mit(mind, traversed_dims_);
--MIIterator match_mit(mind, matched_dims_);
--uint64_t traversed_dims_size = traversed_mit.NumOfTuples();
--uint64_t matched_dims_size = match_mit.NumOfTuples();
--mind->LockAllForUse();
--multi_index_builder_.reset(new MultiIndexBuilder(mind, tips));
--std::vector<DimensionVector> dims_involved = {traversed_dims_, matched_dims_};
--multi_index_builder_->Init(approx_join_size, dims_involved);
--if (traversed_dims_size > 0 && matched_dims_size > 0) {
----TraverseDim(traversed_mit, &outer_tuples);
----outer_tuples_ += outer_tuples;
----if (too_many_conflicts_) {
------tianmu_control_.lock(m_conn->GetThreadID()) << "Too many hash conflicts: restarting join." << system::unlock;
------return;
----joined_tuples += MatchDim(match_mit);
--multi_index_builder_->Commit(joined_tuples, tips.count_only);
--or (int i = 0; i < mind->NumOfDimensions(); i++)
    if (traversed_dims_[i])
      table->SetVCDistinctVals(i,
                               traversed_dist_limit);  // all dimensions involved in traversed side
--mind->UnlockAllFromUse();
```