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
```