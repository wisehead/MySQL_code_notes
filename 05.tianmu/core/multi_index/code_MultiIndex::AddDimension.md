#1.MultiIndex::AddDimension

```
MultiIndex::AddDimension
--no_dimensions++;
  int64_t *ns = new int64_t[no_dimensions];
  DimensionGroup **ng = new DimensionGroup *[no_dimensions];
  int *ngn = new int[no_dimensions];
  for (int i = 0; i < no_dimensions - 1; i++) {
    ns[i] = dim_size[i];
    ng[i] = group_for_dim[i];
    ngn[i] = group_num_for_dim[i];
  }
--delete[] dim_size;
  delete[] group_for_dim;
  delete[] group_num_for_dim;
  dim_size = ns;
  group_for_dim = ng;
  group_num_for_dim = ngn;
  dim_size[no_dimensions - 1] = 0;
  group_for_dim[no_dimensions - 1] = nullptr;
  group_num_for_dim[no_dimensions - 1] = -1;
--for (uint i = 0; i < dim_groups.size(); i++) dim_groups[i]->AddDimension();
```