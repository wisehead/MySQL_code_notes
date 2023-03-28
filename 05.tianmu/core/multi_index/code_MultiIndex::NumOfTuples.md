#1.MultiIndex::NumOfTuples

```
MultiIndex::NumOfTuples
--MultiIndex::ListInvolvedDimGroups
--for (uint i = 0; i < dg.size(); i++) {
----dim_groups[dg[i]]->UpdateNumOfTuples();
------Filter::NumOfOnes
----SafeMultiplication(res, dim_groups[dg[i]]->NumOfTuples());
```