#1.AI解码

```cpp
int
ha_innobase::external_lock(
    THD*   thd,        /*!< in: handle to the user thread */
    int    lock_type)  /*!< in: lock type */
{...
    if (lock_type == F_WRLCK) {
        /* If this is a SELECT, then it is in UPDATE TABLE ...or SELECT ... FOR UPDATE */
        m_prebuilt->select_lock_type = LOCK_X;  // UPDATE TABLE ...或SELECT ...
         FOR UPDATE施加排它锁
        m_prebuilt->stored_select_lock_type = LOCK_X;
    }
    if (lock_type != F_UNLCK) {...
        if (trx->isolation_level == TRX_ISO_SERIALIZABLE //隔离级别是可串行化
            && m_prebuilt->select_lock_type == LOCK_NONE
            && thd_test_options(thd, OPTION_NOT_AUTOCOMMIT | OPTION_BEGIN)) {
             //自动提交
            /* To get serializable execution, we let InnoDBconceptually add 'LOCK
                IN SHARE MODE' to all SELECTs
                which otherwise would have been consistent reads.
                An exception is consistent reads in the AUTOCOMMIT=1 mode:
                we know that they are read-only transactions, and theycan be
                serialized also if performed as consistentreads. */
            //当自动提交且隔离级别是可串行化的情况下，“概念上”加读锁，实际是物理加读锁，这样
              才能保证可串行化的效果，因为读锁排斥写锁
            m_prebuilt->select_lock_type = LOCK_S;  //注意此处是实现可串行化的一段重要代码
            m_prebuilt->stored_select_lock_type = LOCK_S;
        }
...
    } else {
        TrxInInnoDB::end_stmt(trx);
        DEBUG_SYNC_C("ha_innobase_end_statement");
    }
...
}
```



#2.ha_innobase::external_lock

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