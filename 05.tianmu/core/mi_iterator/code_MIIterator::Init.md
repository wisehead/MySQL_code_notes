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
----for (uint i = 0; i < mind->dim_groups.size(); i++)
------if (dim_group_used[i] && (mind->dim_groups[i]->Type() == DimensionGroup::DGType::DG_FILTER ||
                                mind->dim_groups[i]->Type() == DimensionGroup::DGType::DG_VIRTUAL))  // filters first
--------ordering_filters.push_back(std::pair<int, int>(65537 - mind->dim_groups[i]->GetFilter(-1)->DensityWeight(),
                                                       i));  // -1: the default filter for this group
------sort(ordering_filters.begin(),ordering_filters.end()); 
------for (uint i = 0; i < ordering_filters.size(); i++) {  // create iterators for DimensionGroup numbers from sorter
--------it.push_back(mind->dim_groups[ordering_filters[i].second]->NewIterator(dimensions, p_power));
--------dg.push_back(mind->dim_groups[ordering_filters[i].second]);
--------dim_group_used[ordering_filters[i].second] = false;
```