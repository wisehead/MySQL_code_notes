#1.os_file_flush_func

```cpp
os_file_flush_func(
    os_file_t    file)    /*!< in, own: handle to a file */
{
#ifdef _WIN32
...
    ret = FlushFileBuffers(file); //Windows系统把缓存刷出到OS
...
#else
...
    ret = os_file_fsync(file); //非Windows系统把缓存刷出到OS，中会调用系统函数fsync()
函数确保数据一定被刷出。PostgreSQL实现与此差别在于调用fsync()函数是通过参数配置确定，即为了提
高性能，刷出日志到存储分为了几个粒度，fsync是最耗时但在保证REDO日志预写的最严格的保障
...
#endif /* _WIN32 */
}
```

#2.call stack

```cpp

os_file_flush_func(void * file) Line 4020     C++//刷出日志到物理存储介质
fil_flush(unsigned long space_id) Line 5418C++
log_write_flush_to_disk_low() Line 1100C++  //刷出已经被写到日志文件（缓存）的日志到物理存储
log_write_up_to(unsigned __int64 lsn, bool flush_to_disk) Line 1304C++ //确保指定的
LSN的日志已经写出到日志文件（此函数还会被周期性调用刷出日志缓存区的日志信息）
trx_flush_log_if_needed_low(unsigned __int64 lsn) Line 1821C++//根据innodb_flush_
log_at_trx_commit参数确定是否刷出日志到存储
trx_flush_log_if_needed(unsigned __int64 lsn, trx_t * trx) Line 1843C++
trx_commit_complete_for_mysql(trx_t * trx) Line 2497C++
innobase_commit(handlerton * hton, THD * thd, bool commit_trx) Line 4119C++
//不是只读事务，则刷出日志到存储，属于InnoDB层的操作
ha_commit_low(THD * thd, bool all, bool run_after_commit) Line 1754     C++
TC_LOG_DUMMY::commit(THD * thd, bool all) Line 30C++
ha_commit_trans(THD * thd, bool all, bool ignore_global_read_lock) Line 1649C++
trans_commit_stmt(THD * thd) Line 460C++//属于MySQL Server层操的操作
mysql_execute_command(THD * thd, bool first_level) Line 4747C++
mysql_parse(THD * thd, Parser_state * parser_state) Line 5305C++
dispatch_command(THD * thd, const COM_DATA * com_data, enum_server_command
command) Line 1251C++
do_command(THD * thd) Line 819C++ //栈底
```