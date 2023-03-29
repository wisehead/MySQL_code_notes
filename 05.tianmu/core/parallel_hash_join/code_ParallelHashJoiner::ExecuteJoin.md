#1.ParallelHashJoiner::ExecuteJoin

```
ParallelHashJoiner::ExecuteJoin
--MIIterator traversed_mit(mind, traversed_dims_);
--MIIterator match_mit(mind, matched_dims_);
--uint64_t traversed_dims_size = traversed_mit.NumOfTuples();
--uint64_t matched_dims_size = match_mit.NumOfTuples();

```