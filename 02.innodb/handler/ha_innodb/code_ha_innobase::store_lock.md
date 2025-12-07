#1.THR_lock转化为innodb lock

```cpp
THR_LOCK_DATA**
ha_innobase::store_lock(
    THD*              thd,  /*!< in: user thread handle */
    THR_LOCK_DATA**   to,   /*!< in: pointer to the current element in an array
     ofpointers to lock structs;only used as return value */
    thr_lock_type     lock_type)  /*!< in: lock type to store in 'lock';this may
     also be TL_IGNORE */
{...
    if (srv_read_only_mode                               //如果是只读模式
        && !dict_table_is_intrinsic(m_prebuilt->table)   //且不是系统表即是用户表
        && (sql_command == SQLCOM_UPDATE                 //则遇到如下命令时，报告警告信息
            || sql_command == SQLCOM_INSERT
            || sql_command == SQLCOM_REPLACE
            || sql_command == SQLCOM_DROP_TABLE
            || sql_command == SQLCOM_ALTER_TABLE
            || sql_command == SQLCOM_OPTIMIZE
            || (sql_command == SQLCOM_CREATE_TABLE
            //类似CREATE TABLE...SELECT...FRO UPDATE，锁不属于读锁类型而是写锁类型
              则要报告警告
                && (lock_type >= TL_WRITE_CONCURRENT_INSERT && lock_type <= TL_WRITE))
            || sql_command == SQLCOM_CREATE_INDEX
            || sql_command == SQLCOM_DROP_INDEX
            || sql_command == SQLCOM_DELETE)) {
        ib_senderrf(trx->mysql_thd, IB_LOG_LEVEL_WARN, ER_READ_ONLY_MODE);
    } else if (sql_command == SQLCOM_FLUSH&& lock_type == TL_READ_NO_INSERT) {/*
   Check for FLUSH TABLES ... WITH READ LOCK */
...
        if (trx->isolation_level == TRX_ISO_SERIALIZABLE) {
       //对于FLUSH TABLES命令，根据隔离级别施加锁
            m_prebuilt->select_lock_type = LOCK_S;
            //序列化隔离级别施加读锁，这是实现序列化的关键，用共享锁排斥其他写锁
            m_prebuilt->stored_select_lock_type = LOCK_S;
        } else {
            m_prebuilt->select_lock_type = LOCK_NONE;
            m_prebuilt->stored_select_lock_type = LOCK_NONE;
        }
    } else if (sql_command == SQLCOM_DROP_TABLE) {
    //如上一节的例1所示，删除表是在表的元数据上施加了排它锁，故不对锁做调整
        /* MySQL calls this function in DROP TABLE though this tablehandle may
 belong to another thd that is running a query.
        Letus in that case skip any changes to the m_prebuilt struct. */
    } else if ((lock_type == TL_READ && in_lock_tables)/* Check for LOCK TABLE
 t1,...,tn WITH SHARED LOCKS */
           || (lock_type == TL_READ_HIGH_PRIORITY && in_lock_tables)
           || lock_type == TL_READ_WITH_SHARED_LOCKS
           || lock_type == TL_READ_NO_INSERT
           || (lock_type != TL_IGNORE && sql_command != SQLCOM_SELECT)) {
        /* The OR cases above are in this order:
        1) MySQL is doing LOCK TABLES ... READ LOCAL, or weare processing a
 stored procedure or function, or
        2) (we do not know when TL_READ_HIGH_PRIORITY is used), or
        3) this is a SELECT ... IN SHARE MODE, or
        4) we are doing a complex SQL statement likeINSERT INTO ... SELECT ...
and the logical logging (MySQL binlog)
            requires the use of a locking read, orMySQL is doing LOCK TABLES ... READ.
        5) we let InnoDB do locking reads for all SQL statements thatare not
 simple SELECTs;
            note that select_lock_type in this case may get strengthened in
::external_lock() to LOCK_X.
            Note that we MUST use a locking read in all data modifyingSQL statements,
            because otherwise the execution would not beserializable, and also
 the results from the update could be
            unexpected if an obsolete consistent read view would beused. */
        /* Use consistent read for checksum table */
        if (sql_command == SQLCOM_CHECKSUM  //CHECKSUM TABLE只施加的读锁在Parser阶
段完成，要使用一致性读，所以“select_lock_type = LOCK_NONE”
            || ((srv_locks_unsafe_for_binlog|| trx->isolation_level <= TRX_ISO_READ_COMMITTED)
                && trx->isolation_level != TRX_ISO_SERIALIZABLE
                && (lock_type == TL_READ|| lock_type == TL_READ_NO_INSERT)
                && (sql_command == SQLCOM_INSERT_SELECT|| sql_command == SQLCOM_
                REPLACE_SELECT
                    || sql_command == SQLCOM_UPDATE|| sql_command == SQLCOM_
                CREATE_TABLE))) {
            /* If we either have innobase_locks_unsafe_for_binlogoption set or
              this session is using READ COMMITTED
                isolation level and isolation level of the transactionis not set
 to serializable and MySQL is doing
                INSERT INTO...SELECT or REPLACE INTO...SELECTor UPDATE ... =
 (SELECT ...) or
                CREATE  ...SELECT... without FOR UPDATE or IN SHAREMODE in select,
                then we use consistent readfor select. */
            m_prebuilt->select_lock_type = LOCK_NONE;
            m_prebuilt->stored_select_lock_type = LOCK_NONE;
        } else {
            m_prebuilt->select_lock_type = LOCK_S;  //上述情况之外的所有其他情况，使用读锁
            m_prebuilt->stored_select_lock_type = LOCK_S;
        }
    } else if (lock_type != TL_IGNORE) {
        /* We set possible LOCK_X value in external_lock, not yethere even if
       this would be SELECT ... FOR UPDATE */
        m_prebuilt->select_lock_type = LOCK_NONE; //后续一些情况交由external_lock()处理
        m_prebuilt->stored_select_lock_type = LOCK_NONE;
    }
...
}

```

#2.ha_innobase::store_lock

```cpp
ha_innobase::store_lock(
...
        /* Check for FLUSH TABLES ... WITH READ LOCK */
        if (trx->isolation_level == TRX_ISO_SERIALIZABLE) {
                m_prebuilt->select_lock_type = LOCK_S;
                m_prebuilt->stored_select_lock_type = LOCK_S;
        } else {
                m_prebuilt->select_lock_type = LOCK_NONE;
                m_prebuilt->stored_select_lock_type = LOCK_NONE;
        }
...
}
```