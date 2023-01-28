#1.Engine::IsTIANMURoute

```
Engine::IsTIANMURoute
--for (TABLE_LIST *tl = table_list; tl; tl = tl->next_global)
----if (!tl->is_view_or_derived() && !tl->is_view()) 
------if (!IsTianmuTable(tl->table))
--------return table && table->s->db_type() == tianmu_hton;  // table->db_type is always nullptr
--------return false;
------else
--------has_TIANMUTable = true;
-- char *file = GetFilename(selects_list, is_dump);
--return true;
```