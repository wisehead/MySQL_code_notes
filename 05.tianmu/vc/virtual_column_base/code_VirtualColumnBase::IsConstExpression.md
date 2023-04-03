#1.VirtualColumnBase::IsConstExpression

```
VirtualColumnBase::IsConstExpression
--core::MysqlExpression::SetOfVars &vars = expr->GetVars(); 
--//如果var中的table id和所有的alias都关联不上，说明是const的。有道理。
--for (auto &iter : vars) {
    auto ndx_it = std::find(aliases->begin(), aliases->end(), iter.tab);
    if (ndx_it != aliases->end())
      return false;
    else if (iter.tab == temp_table_alias)
      return false;
  }
```