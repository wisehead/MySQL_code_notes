#1.row_sel_get_clust_rec

```cpp

row_sel_get_clust_rec(...)
{...
    if (!node->read_view) {
...
        if (srv_locks_unsafe_for_binlog
            || trx->isolation_level <= TRX_ISO_READ_COMMITTED) {
            lock_type = LOCK_REC_NOT_GAP;
//小于等于已提交读，则不加间隙锁，允许其他事务插入，因此可发生幻象
        } else {
            lock_type = LOCK_ORDINARY;
//大于已提交读，则加间隙锁，防止其他事务插入某个范围内的数据，避免幻象
        }
...}
```