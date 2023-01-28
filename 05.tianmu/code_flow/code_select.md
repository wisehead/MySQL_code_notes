#1.code flow for select

```
mysql_execute_command
--execute_sqlcom_select
----open_tables_for_query
----Tianmu::handler::ha_my_tianmu_query
------ha_tianmu_engine_->HandleSelect
--------Tianmu::core::Engine::IsTIANMURoute
----------if (!IsTianmuTable(tl->table))
------------has_TIANMUTable = true;
--------lock_tables
--------query_cache.store_query(thd, thd->lex->query_tables);
--------Tianmu::core::optimize_select
----------st_select_lex::prepare
----------JOIN::optimize
----------Tianmu::core::Engine::Execute
------------Tianmu::core::Query::Compile
--------------Tianmu::core::Query::AddJoins
--------------AddFields
--------------AddGroupByFields
--------------AddOrderByFields
--------------BuildConditions
--------------AddConds
--------------ApplyConds
--------------cq->BuildTableIDStepsMap();
--------------AddGlobalOrderByFields
------------Tianmu::core::Query::Preexecute
------------Tianmu::core::TempTable::Materialize
------------sender->Finalize(result);
```