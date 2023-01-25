#1.TempTable::Materialize

```
TempTable::Materialize
--CreateDisplayableAttrP
--for (uint i = 0; i < NumOfAttrs(); i++)
    if (attrs[i]->mode != common::ColOperation::LISTING)
      group_by = true;
--no_rows_too_large = filter.mind_->TooManyTuples();
--VerifyAttrsSizes
--if (!group_by && !table_distinct) {
----if (limits_present) {
----} else {
------no_obj = filter.mind_->NumOfTuples();
------local_limit = no_obj;
----output_mind.Clear();
----output_mind.AddDimension_cross(local_limit);
----CalculatePageSize
----if (CanOrderSources())
------TempTable::OrderByAndMaterialize
----if (!materialized_by_ordering)
------if (order_by.size() == 0)
--------FillMaterializedBuffers(local_limit, local_offset, sender, lazy); 
```