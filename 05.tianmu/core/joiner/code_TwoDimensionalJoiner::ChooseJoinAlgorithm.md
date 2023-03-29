#1.TwoDimensionalJoiner::ChooseJoinAlgorithm

```cpp
//两个choose方法
TwoDimensionalJoiner::ChooseJoinAlgorithm
--if (!cond[0].IsType_JoinSimple()) {
    return JoinAlgType::JTYPE_GENERAL;
  }

--if (cond[0].op == common::Operator::O_EQ) {
----return choose_map_or_hash();
```

#2.choose_map_or_hash lambda

```
choose_map_or_hash
--std::vector<CQTerm *> terms = {&cond[0].attr, &cond[0].val1, &cond[0].val2};
--std::for_each(terms.begin(), terms.end(), [&](CQTerm *&tm) {
----//--
--if ((!tianmu_sysvar_force_hashjoin) && (cond.Size() == 1))
----return JoinAlgType::JTYPE_MAP;  // available types checked inside
--return JoinAlgType::JTYPE_HASH;
```

