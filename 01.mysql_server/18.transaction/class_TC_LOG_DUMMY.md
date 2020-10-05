#1.class TC_LOG_DUMMY

```cpp
// 有两个及以上的事务型存储引擎 或者 有一个事务型引擎同时开启了Binlog
if (total_ha_2pc > 1 || (1 == total_ha_2pc && opt_bin_log))
{
  if (opt_bin_log)
    tc_log= &mysql_bin_log;
  else
    tc_log= &tc_log_mmap;
}
// 有一个事务型存储引擎并且关闭了Binlog
else
  tc_log= &tc_log_dummy;
  
// TC_LOG_DUMMY的实现
class TC_LOG_DUMMY: public TC_LOG // use it to disable the logging
{
public:
  TC_LOG_DUMMY() {}
  int open(const char *opt_name)        { return 0; }
  void close()                          { }
  enum_result commit(THD *thd, bool all) {
    return ha_commit_low(thd, all) ? RESULT_ABORTED : RESULT_SUCCESS;
  }
  int rollback(THD *thd, bool all) {
    return ha_rollback_low(thd, all);
  }
  int prepare(THD *thd, bool all) {
    return ha_prepare_low(thd, all);
  }
};
```