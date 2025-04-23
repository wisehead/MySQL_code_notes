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
--FunctionExecutor lock_and_unlock_pack_info(std::bind(&Query::LockPackInfoForUse, &query),
                                             std::bind(&Query::UnlockPackInfoFromUse, &query));
--sender.reset(new ResultSender(selects_list->master_unit()->thd, result_output, selects_list->item_list));
--query.Preexecute(cqu, sender.get());
--if (query.IsRoughQuery())
      result->RoughMaterialize(false, sender.get());
--else
----result->Materialize(false, sender.get()); //!!!!!!!!!!
--sender->Finalize(result);  
--sender.reset();                                      
```