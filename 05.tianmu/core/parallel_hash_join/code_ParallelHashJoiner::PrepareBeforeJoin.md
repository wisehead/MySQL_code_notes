#1.ParallelHashJoiner::PrepareBeforeJoin

```
ParallelHashJoiner::PrepareBeforeJoin
--DimensionVector dims1(mind->NumOfDimensions());  // Initial dimension descriptions
  DimensionVector dims2(mind->NumOfDimensions());
  DimensionVector dims_other(mind->NumOfDimensions());  // dimensions for other conditions, if needed
--for (uint i = 0; i < cond.Size(); i++) {
----if (cond[i].IsType_JoinSimple() && cond[i].op == common::Operator::O_EQ) {
------if (first_found) {
--------hash_descriptors.push_back(i);
--------added = true;
--------cond[i].attr.vc->MarkUsedDims(dims1);
        cond[i].val1.vc->MarkUsedDims(dims2);
        mind->MarkInvolvedDimGroups(dims1);
        mind->MarkInvolvedDimGroups(dims2);
--------if (dims1.Intersects(cond[i].right_dims))
----------dims1.Plus(cond[i].right_dims);        
--------if (dims2.Intersects(cond[i].right_dims))
----------dims2.Plus(cond[i].right_dims);
--------first_found = false;
```