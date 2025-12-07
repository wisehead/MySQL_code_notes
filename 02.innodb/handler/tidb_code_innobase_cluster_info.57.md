#1.innobase_cluster_info

```cpp
innobase_cluster_info
--node_manager::get_cluster_stats
--CLUSTER_STATS*  info = (CLUSTER_STATS*)arg
--lock_nmgr
--node_stats* stats = &info->nodes[i++];
--stats->apply_lsn = node->get_applied_lsn();
--unlock_nmgr
--info->node_count = i;
```

#2.struct CLUSTER_STATS

```cpp
typedef struct st_cluster_stats
{
  uint node_count;
  struct node_stats nodes[16];
} CLUSTER_STATS;
```

#3.register

```cpp	
innobase_init
--innobase_hton->cluster_info = innobase_cluster_info;
```

#4.caller

```cpp
mysqld_list_cluster
--CLUSTER_STATS* cluster_info = NULL;
--cluster_info= (CLUSTER_STATS*)my_malloc(PSI_NOT_INSTRUMENTED,
                                          sizeof(CLUSTER_STATS),
                                          MYF(MY_WME | MY_ZEROFILL));
--hton->cluster_info(hton, cluster_info)
--//read and use the data
--my_free(cluster_info);
```