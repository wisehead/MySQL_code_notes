#1.AggregationAlgorithm::Aggregate

```
AggregationAlgorithm::Aggregate
--GroupByWrapper gbw(t->NumOfAttrs(), just_distinct, m_conn, t->Getpackpower());
--for (uint i = 0; i < t->NumOfAttrs(); i++) {// first pass: find all grouping attributes
----TempTable::Attr &cur_a = *(t->GetAttrP(i));
----if ((just_distinct && cur_a.alias) || cur_a.mode == common::ColOperation::GROUP_BY) {
------if (!already_added) {
--------new_attr_number = gbw.NumOfGroupingAttrs();//0
--------gbw.AddGroupingColumn(new_attr_number, i, *(t->GetAttrP(i)));  // GetAttrP(i) is needed
--------if (upper_approx_of_groups < mind->NumOfTuples()) {
----------dist_vals = gbw.ApproxDistinctVals(new_attr_number, mind);
--for (uint i = 0; i < t->NumOfAttrs(); i++) {  // second pass: find all aggregated attributes
----//-
--t->SetAsMaterialized();
--t->SetNumOfMaterialized(0);
--gbw.Initialize(upper_approx_of_groups);
--if (gbw.IsCountOnly() || mind->ZeroTuples()) {
----//-
--else if (gbw.IsCountDistinctOnly()) {
----//-
--else if (t->GetWhereConds().Size() == 0 &&
           ((gbw.IsMinOnly() && t->NumOfAttrs() == 1 && min_v != common::MINUS_INF_64) ||
            (gbw.IsMaxOnly() && t->NumOfAttrs() == 1 && max_v != common::PLUS_INF_64))) {
----//-
--if (all_done_in_one_row) {
----//-
--else
----MultiDimensionalGroupByScan(gbw, local_limit, offset, sender, limit_less_than_no_groups);            
```