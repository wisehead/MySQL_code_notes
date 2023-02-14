#1.Engine::Execute

```
Engine::Execute
--GetFilename
--if ((selects_list->table_list.elements))
----for (TABLE_LIST *table_ptr = tables; table_ptr; table_ptr = table_ptr->next_leaf) 
------table_ptr->is_derived())
------SELECT_LEX *first_select = table_ptr->derived_unit()->first_select();
------if (first_select->table_list.elements) {
--------exec_direct = false;
--------break;
--query.Compile
```