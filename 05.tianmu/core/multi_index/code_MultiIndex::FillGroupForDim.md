#1.MultiIndex::FillGroupForDim

```
MultiIndex::FillGroupForDim
--int move_groups = 0;
  for (uint i = 0; i < dim_groups.size(); i++) {  // pack all holes
    if (dim_groups[i] == nullptr) {
      while (i + move_groups < dim_groups.size() && dim_groups[i + move_groups] == nullptr) move_groups++;
      if (i + move_groups < dim_groups.size()) {
        dim_groups[i] = dim_groups[i + move_groups];
        dim_groups[i + move_groups] = nullptr;
      } else
        break;
    }
  }
  for (int i = 0; i < move_groups; i++) dim_groups.pop_back();  // clear nulls from the end

  for (int d = 0; d < no_dimensions; d++) {
    group_for_dim[d] = nullptr;
    group_num_for_dim[d] = -1;
  }

  for (uint i = 0; i < dim_groups.size(); i++) {
    for (int d = 0; d < no_dimensions; d++)
      if (dim_groups[i]->DimUsed(d)) {
        group_for_dim[d] = dim_groups[i];
        group_num_for_dim[d] = i;
      }
  }
```