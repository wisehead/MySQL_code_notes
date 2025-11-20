#1.mysql_execute_command

```
mysql_execute_command
--trans_commit_stmt(thd);
```


#2.注释链式事务相关

```cpp
mysql_execute_command(THD *thd)  //MySQL Server层的命令分发器
{...
switch (lex->sql_command) {
    case SQLCOM_BEGIN:  //用户使用BEGIN、START TRANSACTION命令显式开始事务
        if (trans_begin(thd, lex->start_transaction_opt))
        //参见10.3.2节，逐层调用到InnoDB里面，开始事务
...
    case SQLCOM_COMMIT:  //用户使用COMMIT命令显式提交事务
    {...
        bool tx_chain= (lex->tx_chain == TVL_YES ||
       //用户使用COMMIT命令带有“AND [NO] CHAIN”关键字，确定是否要进行链式事务
                                        (thd->variables.completion_type == 1 &&
                                         lex->tx_chain != TVL_NO));
...
        if (trans_commit(thd))  //参见10.3.3节，逐层调用到InnoDB里面，提交事务
            goto error;
        thd->mdl_context.release_transactional_locks();
        /* Begin transaction with the same isolation level. */
        if (tx_chain)   //如果是链式事务，开始新事务，但事务的隔离级别是继承自上一个事务的
        {
            if (trans_begin(thd))  //开始新事务，隔离级别是继承自上一个事务
goto error;
        }
        else   //如果不是链式事务，修改会话（session）的隔离级别为系统配置参数指定的默认值，
               但没有调用trans_begin(thd)开始新事物
        {
            /* Reset the isolation level and access mode if no chaining transaction.*/
            thd->tx_isolation= (enum_tx_isolation) thd->variables.tx_isolation;
            //修改会话（session）的隔离级别为系统配置参数指定的默认值
            thd->tx_read_only= thd->variables.tx_read_only;
        }
...
    }
    case SQLCOM_ROLLBACK:  //参见10.3.5节，逐层调用到InnoDB里面，回滚事务
    {...
        bool tx_chain= (lex->tx_chain == TVL_YES ||
       //用户使用ROLLBACK命令带有“AND [NO] CHAIN”关键字，确定是否要进行链式事务
                                        (thd->variables.completion_type == 1 &&
                                         lex->tx_chain != TVL_NO));
...
        if (trans_rollback(thd))  //回滚新事务，隔离级别是继承自上一个事务
            goto error;
        thd->mdl_context.release_transactional_locks();
        /* Begin transaction with the same isolation level. */
        if (tx_chain)  //如果是链式事务，开始新事务，但事务的隔离级别是继承自上一个事务的
        {
            if (trans_begin(thd))
                goto error;
        }
        else   //如果不是链式事务，修改会话（session）的隔离级别为系统配置参数指定的默认值，
                但没有调用trans_begin(thd)开始新事物
        {
            /* Reset the isolation level and access mode if no chaining transaction.*/
            thd->tx_isolation= (enum_tx_isolation) thd->variables.tx_isolation;
           //修改会话（session）的隔离级别为系统配置参数指定的默认值
            thd->tx_read_only= thd->variables.tx_read_only;
        }
...
    }
    case SQLCOM_RELEASE_SAVEPOINT:  //用户使用RELEASE SAVEPOINT命令显式释放SAVEPOINT
        if (trans_release_savepoint(thd, lex->ident))
...
    case SQLCOM_ROLLBACK_TO_SAVEPOINT:  //用户使用ROLLBACK [WORK] TO [SAVEPOINT]
    命令显式回滚SAVEPOINT
        if (trans_rollback_to_savepoint(thd, lex->ident))
...
    case SQLCOM_SAVEPOINT:  //用户使用SAVEPOINT命令显式命名SAVEPOINT
        if (trans_savepoint(thd, lex->ident))
...
...}
...}

```

#3.非链式事务

```cpp
mysql_execute_command(THD *thd)  //MySQL Server层的命令分发器
{...
finish:  //mysql_execute_command()函数的函数尾部分
...
    if (! thd->in_sub_stmt) //不是多语句事务
    {...
        if (thd->is_error() || (thd->variables.option_bits & OPTION_MASTER_SQL_ERROR))
trans_rollback_stmt(thd);   //如果有错误发生，必须回滚单语句事务，调用ha_rollback_
                               trans()完成回滚
        else
        {
            /* If commit fails, we should be able to reset the OK status. */
            thd->get_stmt_da()->set_overwrite_status(true);
trans_commit_stmt(thd); //否则，提交单语句事务
            thd->get_stmt_da()->set_overwrite_status(false);
        }
...
    }
...
    if (! thd->in_sub_stmt && thd->transaction_rollback_request)
    {
        /*
            We are not in sub-statement and transaction rollback was requested by
            one of storage engines (e.g. due to deadlock). Rollback transaction in
            all storage engines including binary log.
        */
        trans_rollback_implicit(thd); //调用ha_rollback_trans()隐式回滚事务
        thd->mdl_context.release_transactional_locks();
    }
    else if (stmt_causes_implicit_commit(thd, CF_IMPLICIT_COMMIT_END))
    {...
        /* Commit the normal transaction if one is active. */
        trans_commit_implicit(thd); //调用ha_commit_trans()隐式提交事务
        thd->get_stmt_da()->set_overwrite_status(false);
        thd->mdl_context.release_transactional_locks();
    }
...
}

```