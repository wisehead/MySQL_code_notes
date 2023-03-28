#1.MIIterator::GetSliceCapability

```
MIIterator::GetSliceCapability
--if (one_filter_dim > -1) {
----capability.type = SliceCapability::Type::kLinear;
----one_filter_it->GetSlices(&capability.slices);
------slices->resize(fi.GetPackCount(), 1 << fi.GetPackPower());
```