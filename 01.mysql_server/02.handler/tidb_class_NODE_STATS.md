#1.class NODE_STATS

```cpp
/* InnoDB log stats for tidb */
class NODE_STATS
{

  stats_base base;

  stats_slave slave;

  stats_master master;

  mysql_mutex_t mutex;

  std::vector<stats_hosts> host_info;
};
```