#1.trx_savepoint_for_mysql

```cpp
/*******************************************************************//**
Creates a named savepoint. If the transaction is not yet started, starts it.
If there is already a savepoint of the same name, this call erases that old
savepoint and replaces it with a new. Savepoints are deleted in a transaction
commit or rollback.
@return always DB_SUCCESS */
dberr_t
trx_savepoint_for_mysql(
    trx_t*      trx,          /*!< in: transaction handle */
    const char*savepoint_name,  /*!< in: savepoint name */
    int64_t     binlog_cache_pos) /*!< in: MySQL binlog cacheposition
    corresponding to thisconnection at the time of thesavepoint */
{...
    trx_start_if_not_started_xa(trx, false); //如果没有开始一个事务，则开始一个新事务
    savep = trx_savepoint_find(trx, savepoint_name); //查找指定名称的savepoint
    if (savep) {  //存在指定名称的savepoint则先释放
        /* There is a savepoint with the same name: free that */
        UT_LIST_REMOVE(trx->trx_savepoints, savep);
        ut_free(savep->name);
        ut_free(savep);
    }
    /* Create a new savepoint and add it as the last in the list */
    savep = static_cast<trx_named_savept_t*>(ut_malloc_nokey(sizeof(*savep)));
    savep->name = mem_strdup(savepoint_name);
    savep->savept = trx_savept_take(trx); //创建一个trx_savept_t对象
    savep->mysql_binlog_cache_pos = binlog_cache_pos;
    UT_LIST_ADD_LAST(trx->trx_savepoints, savep);
    return(DB_SUCCESS);
}
```