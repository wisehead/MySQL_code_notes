#1.continue_unfinished_pst_cmd

```cpp
continue_unfinished_pst_cmd
--pst->cleanup_stmt
--pst->state= Query_arena::STMT_EXECUTED;
--pst->set_pst_prepare();
--thd->pop_reprepare_observer();
--thd->set_protocol(thd->pst_protocol);

```