#1.AggregationAlgorithm::Aggregate

```
AggregationAlgorithm::Aggregate
--GroupByWrapper gbw(t->NumOfAttrs(), just_distinct, m_conn, t->Getpackpower());
--for (uint i = 0; i < t->NumOfAttrs(); i++) {
----TempTable::Attr &cur_a = *(t->GetAttrP(i));
----if ((just_distinct && cur_a.alias) || cur_a.mode == common::ColOperation::GROUP_BY) {
------if (!already_added) {
--------new_attr_number = gbw.NumOfGroupingAttrs();//0
--------gbw.AddGroupingColumn(new_attr_number, i, *(t->GetAttrP(i)));  // GetAttrP(i) is needed
--------if (upper_approx_of_groups < mind->NumOfTuples()) {
----------dist_vals = gbw.ApproxDistinctVals(new_attr_number, mind);
```