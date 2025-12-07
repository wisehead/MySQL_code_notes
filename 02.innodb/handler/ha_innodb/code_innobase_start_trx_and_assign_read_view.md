#1.innobase_start_trx_and_assign_read_view

```cpp
innobase_start_trx_and_assign_read_view(
//在可重复读隔离级别下创建一个快照，其他隔离级别则不创建快照
    handlerton*    hton,    /*!< in: InnoDB handlerton */
    THD*           thd)     /*!< in: MySQL thread handle of the user for whom the
    transaction should be committed */
{...
    if (trx->isolation_level == TRX_ISO_REPEATABLE_READ) {
    //如果是RR隔离级别，则给read view赋值，即构建一致性视图
        trx_assign_read_view(trx);
        //为读一致性视图（快照）赋一个值，注意在store_lock()中应隔离级别小于RR才关闭快照
    } else {
        push_warning_printf(thd, Sql_condition::SL_WARNING,
                    HA_ERR_UNSUPPORTED,
                    "InnoDB: WITH CONSISTENT SNAPSHOT"
                    " was ignored because this phrase"
                    " can only be used with"
                    " REPEATABLE READ isolation level.");
    }
...
}
```