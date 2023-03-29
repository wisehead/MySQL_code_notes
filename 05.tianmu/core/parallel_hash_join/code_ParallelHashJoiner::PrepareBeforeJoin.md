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
--cond_hashed_ = int(hash_descriptors.size());
--bool switch_sides = false;
  int64_t dim1_size = mind->NumOfTuples(dims1);
  int64_t dim2_size = mind->NumOfTuples(dims2);
--if (std::min(dim1_size, dim2_size) > 100000) {  // approximate criteria for large tables (many packs)
----if (dim1_size > 2 * dim2_size)
------switch_sides = true;  
--if (switch_sides) {
---for (int i = 0; i < cond_hashed_; i++)  // switch sides of joining conditions
------cond[hash_descriptors[i]].SwitchSides();

```