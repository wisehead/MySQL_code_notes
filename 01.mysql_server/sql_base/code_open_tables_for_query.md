#1.open_tables_for_query


```cpp
bool open_tables_for_query(THD *thd, TABLE_LIST *tables, uint flags)
{
    DML_prelocking_strategy prelocking_strategy;
    MDL_savepoint mdl_savepoint= thd->mdl_context.mdl_savepoint();
    //记录下本过程开始前的锁的情况（记录本代码段之前的锁是谁）
…
    if (open_tables(thd, &tables, &thd->lex->table_count, flags,&prelocking_
    strategy)) //打开表
        goto end; //打开表失败，表示有异常，需要做异常处理
    DBUG_RETURN(0);
end:  //有异常，需要关闭表，释放这个过程中施加的锁
…
    close_thread_tables(thd);
    /* Don't keep locks for a failed statement. */
    thd->mdl_context.rollback_to_savepoint(mdl_savepoint);
   //回滚，就是调用MDL_context::rollback_to_savepoint()释放这个过程中施加的锁
    DBUG_RETURN(TRUE); /* purecov: inspected */
}
```