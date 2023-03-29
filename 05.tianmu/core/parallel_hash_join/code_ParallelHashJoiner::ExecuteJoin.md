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
```