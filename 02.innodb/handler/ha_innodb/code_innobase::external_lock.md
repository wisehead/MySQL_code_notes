#1.a_innobase::external_lock

```cpp
ha_innobase::external_lock(...)
{...
    if (lock_type != F_UNLCK) {
        /* MySQL is setting a new table lock */
...
        if (trx->isolation_level == TRX_ISO_SERIALIZABLE  //可串行化隔离级别
            && m_prebuilt->select_lock_type == LOCK_NONE
            && thd_test_options(thd, OPTION_NOT_AUTOCOMMIT | OPTION_BEGIN)) {
              //且在一个显式事务块内部
            /* To get serializable execution, we let InnoDB conceptually add
            'LOCK IN SHARE MODE' to all SELECTs
            which otherwise would have been consistent reads. An exception is
            consistent reads in the AUTOCOMMIT=1 mode:
            we know that they are read-only transactions, and they can be
            serialized also if performed as consistent reads. */
            m_prebuilt->select_lock_type = LOCK_S;  //加读锁，即'LOCK IN SHARE MODE'
            m_prebuilt->stored_select_lock_type = LOCK_S;
        }  //否则，不加锁（这一点也很重要）
...
    } else {
        TrxInInnoDB::end_stmt(trx);
        DEBUG_SYNC_C("ha_innobase_end_statement");
    }
...}
```