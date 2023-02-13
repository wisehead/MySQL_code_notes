#1.Engine::HandleSelect

```
/*
Handles a single query
If an error appears during query preparation/optimization
query structures are cleaned up and the function returns information about the error through res'. If the query can not be compiled by Tianmu engine
QueryRouteTo::kToMySQL is returned and MySQL engine continues query
execution.
*/

Engine::HandleSelect
--if (!IsTIANMURoute)
----return QueryRouteTo::kToMySQL;
--lock_tables
--query_cache.store_query(thd, thd->lex->query_tables);
--if (thd->fill_derived_tables() && lex->derived_tables) 
----//return !stmt_arena->is_stmt_prepare() && !lex->only_view_structure();
----for (SELECT_LEX *sl = lex->all_selects_list; sl; sl = sl->next_select_in_list())        // for all selects
------for (TABLE_LIST *cursor = sl->get_table_list(); cursor; cursor = cursor->next_local)  // for all tables
--------if (cursor->table && cursor->is_view_or_derived()) {  // data source (view or FROM subselect)
--if (select_lex->next_select()) {  // it is union
--else
----unit->set_limit(unit->global_parameters());
----optimize_select

```

#2.caller

```
ha_my_tianmu_query
```