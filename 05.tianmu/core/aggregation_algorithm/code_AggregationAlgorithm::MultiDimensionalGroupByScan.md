#1.AggregationAlgorithm::MultiDimensionalGroupByScan

```
AggregationAlgorithm::MultiDimensionalGroupByScan
--gbw.FillDimsUsed(dims);
--gbw.SetDistinctTuples(mit.NumOfTuples());
--AggregationWorkerEnt ag_worker(gbw, mind, thd_cnt, this);
--cur_tuple = 0;
--gbw.ClearNoGroups();         // count groups locally created in this pass
--gbw.ClearDistinctBuffers();  // reset buffers for a new contents
--gbw.AddAllGroupingConstants(mit);
--ag_worker.Init(mit);
--if (ag_worker.ThreadsUsed() > 1) {
----//-
--else
----thread_type = "sin";
----while (mit.IsValid()) {
------packrow_length = mit.GetPackSizeLeft();
------grouping_result = AggregatePackrow(gbw, &mit, cur_tuple, &mem_used);
```