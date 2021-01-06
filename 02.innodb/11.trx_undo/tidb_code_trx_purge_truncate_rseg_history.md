#1.trx_purge_truncate_rseg_history

```cpp
// 删除一个 rseg 中的 undo log record
trx_purge_truncate_rseg_history
  // 由尾至头遍历 history list，即首先拿到最后一个 undo log（最老的，采用头插法，trx no 由尾至头递增）。
  // 注意 history list 上连接的是 Undo Log Header
  hdr_addr = trx_purge_get_log_from_hist(flst_get_last(rseg_hdr + TRX_RSEG_HISTORY, &mtr));
  // 在相同的数据页上得到 seg header
  seg_hdr = undo_page + TRX_UNDO_SEG_HDR; 
  // 如果
  //   1- undo log segement 上的最新的活跃事务已经提交，且状态是 TRX_UNDO_TO_PURGE
  //   2- 目前遍历到的 undo log 是该 undo log segement 的最后一个事务（已全部遍历完成）
  if ((mach_read_from_2(seg_hdr + TRX_UNDO_STATE) == TRX_UNDO_TO_PURGE) &&
      (mach_read_from_2(log_hdr + TRX_UNDO_NEXT_LOG) == 0)) 
    // 释放整个 segment
  else
    // 否则只把这个 undo log hdr 从 history list 上摘除
    
```