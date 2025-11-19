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