#1.Query::Compile

```
Query::Compile
--for (SELECT_LEX *sl = selects_list; sl; sl = sl->next_select()) 
----SetLimit(sl, sl == selects_list ? 0 : sl->join->unit->global_parameters(), offset_value, limit_value);
----Item *conds = (ifNewJoinForTianmu || !sl->join->where_cond) ? sl->where_cond() : sl->join->where_cond;
----for (TABLE_LIST *table_ptr = tables; table_ptr; table_ptr = table_ptr->next_leaf) {
------if (!table_ptr->is_view_or_derived()) 
--------if (!Engine::IsTianmuTable(table_ptr->table))
            throw CompilationError();
--------AddTable(m_conn->GetTableByPath(path));
------// partial optimization of LOJ conditions, JOIN::optimize(part=3)
      // necessary due to already done basic transformation of conditions
      // see comments in sql_select.cc:JOIN::optimize()
------if (IsLOJ(join_list))
        sl->join->optimize(OptimizePhase::Finish_LOJ_Transform);
------for (TABLE_LIST *table_ptr = tables; table_ptr; table_ptr = table_ptr->next_leaf) {
--------std::string path = TablePath(table_ptr);
--------if (path2num.find(path) == path2num.end()) {
----------path2num[path] = NumOfTabs();
----------AddTable(m_conn->GetTableByPath(path));
----AddJoins
----AddFields
```