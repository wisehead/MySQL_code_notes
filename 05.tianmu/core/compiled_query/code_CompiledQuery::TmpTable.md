#1.CompiledQuery::TmpTable

```
CompiledQuery::TmpTable
--  CompiledQuery::CQStep s;
  if (for_subq_in_where)
    s.n1 = 1;
  else
    s.n1 = 0;
  DEBUG_ASSERT(t1.n < 0 && NumOfTabs() > 0);
  s.type = StepType::TMP_TABLE;
  s.t1 = t_out = NextTabID();  // was s.t2!!!
  s.tables1.push_back(t1);
  steps_tmp_tables.push_back(s);
  steps.push_back(s);
```