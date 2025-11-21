#1.snapshot_handlerton

```cpp
static my_bool snapshot_handlerton(THD *thd, plugin_ref plugin, void *arg)
{
    handlerton *hton= plugin_data<handlerton*>(plugin);
    if (hton->state == SHOW_OPTION_YES && hton->start_consistent_snapshot)
    //隔离级别是RR时start_consistent_snapshot才被赋值
    {
        hton->start_consistent_snapshot(hton, thd);
       //对于InnoDB，实际执行innobase_start_trx_and_assign_read_view()函数
        *((bool *)arg)= false;
    }
    return FALSE;
}
```

innobase_start_trx_and_assign_read_view