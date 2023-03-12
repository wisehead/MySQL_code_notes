#1.RoughMultiIndex::GetLocalDescFilter

```
//RoughMultiIndex的粗糙集，和RF区分开。RF是针对全局的，localDescFilter是针对条件的。
RoughMultiIndex::GetLocalDescFilter
--for (j = 0; j < local_desc[dim].size(); j++) {
    if ((local_desc[dim])[j]->desc_num == desc_num)
      return (local_desc[dim])[j]->desc_rf;
--local_desc[dim].push_back(new RFDesc(no_packs[dim], desc_num));
--for (int p = 0; p < no_packs[dim]; p++) {
----if (rf[dim][p] == common::RoughSetValue::RS_NONE)  // check global dimension filter
------(local_desc[dim])[j]->desc_rf[p] = common::RoughSetValue::RS_NONE;
----else
------(local_desc[dim])[j]->desc_rf[p] = common::RoughSetValue::RS_UNKNOWN;
--return (local_desc[dim])[j]->desc_rf;
```