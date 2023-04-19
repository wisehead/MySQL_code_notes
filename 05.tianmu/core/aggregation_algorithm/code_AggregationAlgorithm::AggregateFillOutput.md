#1.AggregationAlgorithm::AggregateFillOutput

```
AggregationAlgorithm::AggregateFillOutput
--int64_t cur_output_tuple;
--cur_output_tuple = t->NumOfObj();
--t->SetNumOfMaterialized(cur_output_tuple + 1);  // needed to allow value reading from this TempTable
--for (uint i = 0; i < t->NumOfAttrs(); i++) {
----TempTable::Attr *a = t->GetAttrP(i);  // change to pointer - for speed
----if (ATI::IsStringType(a->TypeName())) {
------a->SetValueString(cur_output_tuple, gbw.GetValueT(gt_column, gt_pos));
--for (uint i = 0; i < t->NumOfAttrs(); i++) {
----
```