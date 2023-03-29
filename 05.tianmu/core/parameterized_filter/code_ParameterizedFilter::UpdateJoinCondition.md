#1.ParameterizedFilter::UpdateJoinCondition

```
ParameterizedFilter::UpdateJoinCondition
--DimensionVector all_involved_dims(mind_->NumOfDimensions());
--ParameterizedFilter::RoughSimplifyCondition
--for (uint i = 0; i < cond.Size(); i++) cond[i].DimensionUsed(all_involved_dims);
--bool is_outer = cond[0].IsOuter();
--int conditions_used = cond.Size();
--join_alg = TwoDimensionalJoiner::ChooseJoinAlgorithm(*mind_, cond);
```

