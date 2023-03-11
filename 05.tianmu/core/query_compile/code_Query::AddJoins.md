#1.Query::AddJoins

```
Query::AddJoins
--for (unsigned int i = 0; i < size; i++) {
----if (join_ptr->nested_join) {
----else
------if (join_ptr->is_view_or_derived()) {
--------Query::Compile
------else
--------TableUnmysterify
--------cq->TableAlias(tab, TabID(tab_num), table_name, id)
----------s.type = StepType::TABLE_ALIAS;
--------table_alias2index_ptr.insert(std::make_pair(ext_alias, std::make_pair(tab.n, join_ptr->table)));
------if (first_table) 
--------left_tables.push_back(tab);
--------cq->TmpTable(tmp_table, tab, for_subq_in_where);
----------s.type = StepType::TMP_TABLE;
------else
--------cq->Join(tmp_table, tab);
--------GetJoinTypeAndCheckExpr
--------BuildCondsIfPossible
--------if (join_ptr->join_cond() && join_ptr->outer_join) {
--------} else if (join_ptr->join_cond() && !join_ptr->outer_join) {
--------else
----------left_tables.push_back(tab);
```