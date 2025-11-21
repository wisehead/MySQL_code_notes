#1.ha_innobase::unlock_row

```cpp

/** Removes a new lock set on a row, if it was not read optimistically. This can
 be called after a row has been read
in the processing of an UPDATE or a DELETE query, if the option innodb_locks_
unsafe_for_binlog is set. */
void    //被mysql_update()/mysql_delete()调用，用于为记录解锁。另外少数情况是：被join_
read_key()等调用
ha_innobase::unlock_row(void)   //在UPDATE或DELETE执行时，一个元组被读取操作后，所施加
的锁“可能”被本方法释放
{...                            //所施加的锁是否被释放，取决于下面对隔离级别的判断
    switch (m_prebuilt->row_read_type) {
    case ROW_READ_WITH_LOCKS:
        if (!srv_locks_unsafe_for_binlog
            && m_preb uilt->trx->isolation_level
            > TRX_ISO_READ_COMMITTED) {
            //隔离级别是可重复读或可串行化，则满足大于已提交读，所以执行break不解锁
            break;
        }
        /* fall through */
    case ROW_READ_TRY_SEMI_CONSISTENT:
        row_unlock_for_mysql(m_prebuilt, FALSE);
        //如果是已提交读隔离级别，则能执行到解锁操作
        break;  //意味着已提交读隔离级别加锁过后，则释放锁，而不是等待事务结束时释放锁。所以
                  更新等操作可以被其他事务有机会看到
    case ROW_READ_DID_SEMI_CONSISTENT:
        m_prebuilt->row_read_type = ROW_READ_TRY_SEMI_CONSISTENT;
        break;
    }
...
}
```