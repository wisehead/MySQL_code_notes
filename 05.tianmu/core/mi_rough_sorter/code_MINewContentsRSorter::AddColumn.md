#1.MINewContentsRSorter::AddColumn

```
MINewContentsRSorter::AddColumn
--tall[dim] = t;
  tcheck[dim] = false;
  if (t) {
    tsort[no_cols_to_sort++] = t;
    if (mind->OrigSize(dim) > (1U << p_power)) {
      tcomp[no_cols_to_compare++] = tall[dim];
      tcheck[dim] = true;
    }
  }
```