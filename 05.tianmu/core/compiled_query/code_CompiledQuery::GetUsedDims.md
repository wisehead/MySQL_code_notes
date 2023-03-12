#1.CompiledQuery::GetUsedDims

```
CompiledQuery::GetUsedDims
--auto itsteps = TabIDSteps.equal_range(table_id);//multimap可以这样用，获取一个范围。
--for (auto it = itsteps.first; it != itsteps.second; ++it) {
----if (step.type == CompiledQuery::StepType::ADD_COLUMN && step.t1 == table_id &&
        step.e1.vc_id != common::NULL_VALUE_32) {
------vcolumn::VirtualColumn *vc = ((TempTable *)ta[-table_id.n - 1].get())->GetVirtualColumn(step.e1.vc_id);
------local = vc->GetDimensions();
------result.insert(local.begin(), local.end());
```