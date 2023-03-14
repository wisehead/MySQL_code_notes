#1.RoughMultiIndex::UpdateGlobalRoughFilter


```
RoughMultiIndex::UpdateGlobalRoughFilter
--loc_rs = GetLocalDescFilter(dim, desc_num, true);
--for (int p = 0; p < no_packs[dim]; p++) {
    if (rf[dim][p] == common::RoughSetValue::RS_UNKNOWN) {  // not known yet - get the first
                                                            // information available
      rf[dim][p] = loc_rs[p];
      if (rf[dim][p] != common::RoughSetValue::RS_NONE)
        any_nonempty = true;
    } else if (loc_rs[p] == common::RoughSetValue::RS_NONE)
      rf[dim][p] = common::RoughSetValue::RS_NONE;
    else if (rf[dim][p] != common::RoughSetValue::RS_NONE) {  // else no change
      any_nonempty = true;
      if (loc_rs[p] != common::RoughSetValue::RS_ALL ||
          rf[dim][p] != common::RoughSetValue::RS_ALL)  // else rf[..] remains common::RoughSetValue::RS_ALL
        rf[dim][p] = common::RoughSetValue::RS_SOME;
    }
```