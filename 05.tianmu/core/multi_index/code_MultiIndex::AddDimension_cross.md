#1.MultiIndex::AddDimension_cross


```
MultiIndex::AddDimension_cross
--MultiIndex::AddDimension
--if (size > 0) 
----dim_size[new_dim] = size;
----nf = new DimensionGroupFilter(new_dim, size, p_power);  // redo
--dim_groups.push_back(nf);
--group_for_dim[new_dim] = nf;
--group_num_for_dim[new_dim] = int(dim_groups.size() - 1);
--can_be_distinct.push_back(true);  // may be modified below
--CheckIfVirtualCanBeDistinct();
```