#1.srv_purge_coordinator_thread

```cpp
srv_purge_coordinator_thread
  |- srv_do_purge
    |- trx_purge
        // 获取事务系统中最老的视图
        |- read_view_purge_open
        // 1. 聚簇索引/辅助索引中DEL_BIT=1数据记录的清理
        |- trx_purge_attach_undo_recs
          |- trx_purge_fetch_next_rec // 从History List中读取日志记录
            // 【1】从最小堆顶部弹出保存着最小事务no的回滚段
            // 【2】获得该回滚段中最老的事务T_min
            |- trx_purge_choose_next_log 
            // 【3】顺序读取当前（历史）事务的Undo日志
            |- trx_purge_get_next_rec
              // 【4】【5】 如果当前事务的Undo日志读取完毕，将History List中的前一个事务（次小）压入最小堆中
              |- trx_purge_rseg_get_next_history_log
        // 2. History List中update_undo日志记录的清理
        |- trx_purge_truncate

```
