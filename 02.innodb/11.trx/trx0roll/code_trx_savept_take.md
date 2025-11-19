#1.trx_savept_take

```cpp

/*******************************************************************//**
Returns a transaction savepoint taken at this point in time.
@return savepoint */
trx_savept_t
trx_savept_take(
    trx_t*    trx)    /*!< in: transaction */{
    trx_savept_t    savept;
    savept.least_undo_no = trx->undo_no; //如此简单的一个赋值，即做一个位置标识，且是回
    滚段的标识，可以看出，InnoDB的Savepoint依赖回归段实现，十分简单简洁
    return(savept);
}
```