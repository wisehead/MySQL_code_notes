#1.CompiledQuery::TableAlias

```
CompiledQuery::TableAlias
--CompiledQuery::CQStep s;
  s.type = StepType::TABLE_ALIAS;
  s.t1 = t_out = NextTabID();
  s.t2 = n;
  if (name) {
    s.alias = new char[std::strlen(name) + 1];
    std::strcpy(s.alias, name);
  }
  steps.push_back(s);
```