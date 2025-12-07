#1.ha_innobase::try_semi_consistent_read

```cpp

ha_innobase::try_semi_consistent_read(bool yes)  //决定是否可以进行半一致性读
{...
    /* Row read type is set to semi consistent read if this was requested by the
    MySQL and either
       innodb_locks_unsafe_for_binlog option is used or this session is using
       READ COMMITTED isolation level. */
    if (yes  //表扫描或索引扫描
        && (srv_locks_unsafe_for_binlog
        || m_prebuilt->trx->isolation_level <= TRX_ISO_READ_COMMITTED)) {
        //只有隔离级别小于等已提交读，才可进行半一致性读
        m_prebuilt->row_read_type = ROW_READ_TRY_SEMI_CONSISTENT;
    } else {  //非表扫描或索引扫描，如全文检索时yes参数值为false
        m_prebuilt->row_read_type = ROW_READ_WITH_LOCKS;
    }
}
```