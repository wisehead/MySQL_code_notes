#1.ha_commit_trans

```cpp
int ha_commit_trans(THD *thd, bool all, bool ignore_global_read_lock)
{
  if (ha_info)
  {
    if (!trans->no_2pc && (rw_ha_count > 1)) // 关闭Binlog后，rw_ha_count（读写插件数目）为1
      error= tc_log->prepare(thd, all); // Prepare阶段
  }
  
  if (error || (error= tc_log->commit(thd, all))) // Commit阶段,比如只有InnoDB（即调用innobase_commit）
  {
    ha_rollback_trans(thd, all); // 若提交失败则回滚
    error= 1;
    goto end;
  }
}
```