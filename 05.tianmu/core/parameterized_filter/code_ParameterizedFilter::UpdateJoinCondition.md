#1.ParameterizedFilter::UpdateJoinCondition

```
ParameterizedFilter::UpdateJoinCondition
--DimensionVector all_involved_dims(mind_->NumOfDimensions());
--ParameterizedFilter::RoughSimplifyCondition
--for (uint i = 0; i < cond.Size(); i++) cond[i].DimensionUsed(all_involved_dims);
--bool is_outer = cond[0].IsOuter();
--int conditions_used = cond.Size();
--join_alg = TwoDimensionalJoiner::ChooseJoinAlgorithm(*mind_, cond);
--do
----auto joiner = TwoDimensionalJoiner::CreateJoiner(join_alg, *mind_, tips, table_);
----joiner->ExecuteJoinConditions(cond);
----if (join_result != TwoDimensionalJoiner::JoinFailure::NOT_FAILED)
------join_alg = TwoDimensionalJoiner::ChooseJoinAlgorithm(join_result, join_alg, cond.Size());
--for (int i = 0; i < conditions_used; i++) cond.EraseFirst();  // erase the first condition (already used)
--mind_->UpdateNumOfTuples();
--DisplayJoinResults(all_involved_dims, join_alg, is_outer, conditions_used);
```

