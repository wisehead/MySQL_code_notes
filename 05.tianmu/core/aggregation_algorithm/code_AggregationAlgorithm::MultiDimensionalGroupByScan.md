#1.AggregationAlgorithm::MultiDimensionalGroupByScan

```
AggregationAlgorithm::MultiDimensionalGroupByScan
--gbw.FillDimsUsed(dims);
--gbw.SetDistinctTuples(mit.NumOfTuples());
--AggregationWorkerEnt ag_worker(gbw, mind, thd_cnt, this);
--while (gbw.AnyTuplesLeft() && (1 == thd_cnt));
----cur_tuple = 0;
----gbw.ClearNoGroups();         // count groups locally created in this pass
----gbw.ClearDistinctBuffers();  // reset buffers for a new contents
----gbw.AddAllGroupingConstants(mit);
----ag_worker.Init(mit);
----if (ag_worker.ThreadsUsed() > 1) {
------//-
----else
------thread_type = "sin";
------while (mit.IsValid()) {
--------packrow_length = mit.GetPackSizeLeft();
--------grouping_result = AggregatePackrow(gbw, &mit, cur_tuple, &mem_used);
--------cur_tuple += packrow_length;
----MultiDimensionalDistinctScan(gbw, mit); 
----ag_worker.Commit();
----if (first_pass) {
------upper_groups = gbw.NumOfGroups() + gbw.TuplesNoOnes();
------t->CalculatePageSize(upper_groups);
------output_size = (gbw.NumOfGroups() + gbw.TuplesNoOnes()) * t->GetOneOutputRecordSize();
------if (t->GetPageSize() >= (gbw.NumOfGroups() + gbw.TuplesNoOnes()) && output_size > (1L << 29) &&
--          !t->HasHavingConditions() && tianmu_sysvar_parallel_filloutput) {
--------//-
------else
--------while (gbw.RowValid()) {
----------AggregateFillOutput(gbw, gbw.GetCurrentRow(), offset);
----------gbw.NextRow();
--------if (sender) {
----------//
--------else
----------displayed_no_groups = t->NumOfObj();
```