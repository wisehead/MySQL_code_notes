#1.MIIterator::Init

```
MIIterator::Init
--mii_type = MIIteratorType::MII_NORMAL;
--for (uint i = 0; i < mind->dim_groups.size(); i++) dim_group_used[i] = false;
--for (int i = 0; i < no_dims; i++)
----if (dimensions[i]) {
------dim_group_used[mind->group_num_for_dim[i]] = true;
------mind->LockForGetIndex(i);
--------MultiIndex::LockForGetIndex
--for (uint i = 0; i < mind->dim_groups.size(); i++) {
----if (dim_group_used[i]) {
      no_obj = SafeMultiplication(no_obj, mind->dim_groups[i]->NumOfTuples());
      zero_tuples = false;
----} else {
------omitted_factor = SafeMultiplication(omitted_factor, mind->dim_groups[i]->NumOfTuples());
--if (no_dims > 0) {
----it_for_dim = new int[no_dims];
----
```