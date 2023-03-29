#1.ExpressionColumn::ExpressionColumn

```
ExpressionColumn::ExpressionColumn
--const std::vector<core::JustATable *> *tables = &temp_table->GetTables();
--const std::vector<int> *aliases = &temp_table->GetAliases();
--if (expr_) {
----vars_ = expr_->GetVars();  
----first_eval_ = true;
----for (auto &v : vars_) {
------auto ndx_it = find(aliases->begin(), aliases->end(), v.tab);
------if (ndx_it != aliases->end()) {
--------int ndx = int(distance(aliases->begin(), ndx_it));
--------var_map_.push_back(VarMap(v, (*tables)[ndx], ndx));
--------if (only_dim_number == -2 || only_dim_number == ndx)
----------only_dim_number = ndx;
--------var_types_[v] = (*tables)[ndx]->GetColumnType(var_map_[var_map_.size() - 1].col_ndx);
--------var_buf_[v] = std::vector<core::MysqlExpression::value_or_null_info_t>();  // now empty, pointers
----ct = core::ColumnType(expr_->EvalType(&var_types_)); 
```