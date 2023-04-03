#1.ParameterizedFilter::PrepareJoiningStep

```
ParameterizedFilter::PrepareJoiningStep
--DimensionVector dims1(mind_.NumOfDimensions());
--desc[desc_no].DimensionUsed(dims1);
--mind_.MarkInvolvedDimGroups(dims1);
--for (uint i = desc_no; i < desc.Size(); i++) {
----if (desc[i].right_dims == cur_outer_dim && (outer_present || dims1.Includes(dims2))) {
      // can be executed together if all dimensions of the other condition are
      // present in the base one or in case of outer join
------join_desc.AddDescriptor(desc[i]);
------desc[i].done = true;  // setting in advance, as we already copied the
                            // descriptor to be processed
--// add the rest of conditions (e.g. one-dimensional outer conditions), which
  // are not "done" yet
  for (uint i = desc_no; i < desc.Size(); i++) {
    if (desc[i].done || desc[i].IsDelayed())
      continue;
```