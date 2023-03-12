#1.ParameterizedFilter::SyntacticalDescriptorListPreprocessing

```
ParameterizedFilter::SyntacticalDescriptorListPreprocessing
--for (uint i = 0; i < no_desc; i++) {  
----descriptors_[i].CoerceColumnTypes();
------Descriptor::CoerceColumnType
------CoerceCollation
----descriptors_[i].Simplify();
------if ((attr.vc && (!attr.vc->IsConst() || (in_having && attr.vc->IsParameterized()))) ||
      (val1.vc && (!val1.vc->IsConst() || (in_having && val1.vc->IsParameterized()))) ||
      (val2.vc && (!val2.vc->IsConst() || (in_having && val2.vc->IsParameterized())))) {
    return;
--if (!false_desc) {
----for (uint i = 0; i < no_desc; i++) {
------descriptors_[i].DimensionUsed(all_dims);
--------if (attr.vc)
----------attr.vc->MarkUsedDims(dims);
--------if (val1.vc)
----------val1.vc->MarkUsedDims(dims);
------ConditionEncoder::EncodeIfPossible(descriptors_[i], for_rough_query, additional_nulls_possible);
--------ConditionEncoder ce(additional_nulls, desc.table->Getpackpower());
--------ce(desc);
--------desc.Simplify();
----//// descriptor merging
----for (uint i = 0; i < no_desc; i++) {
------//do nothing
```