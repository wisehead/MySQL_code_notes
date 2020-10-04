#1. row_search_mvcc

```cpp
row_search_mvcc {
  mtr_start(mtr);
     
  // Step-1: 在 B-tree 中放置 cursor，或 restore 一个已有的 cursor
  // direction 是 ROW_SEL_PREV/ROW_SEL_NEXT，表示是 range scan
  if（direction != 0）
    // cursor(pcur) 之前已被放置在叶子节点内的某一位置，"restore" 的意思将 cursor 重新指向之前的位置。有两个办法：
    //  1- 乐观恢复：之前指向数据页的 modify clock （m_modify_clock）若没有改变，则可以直接 latch 住该页
    //             restore cursor 完成
    //  2- 悲观恢复：之前指向数据页的 modify clock 有改变（数据页上的记录被 reorganize，或者某些记录被删除），无法
    //             确定 pcur
    // （m_btr_cur）是否还有效，根据保存的记录（m_old_rec）来重新 traverse B-tree（row_search_to_nth_level）
    need_to_process = sel_restore_position_for_mysql
    // IMPORTANT：goto 的使用使得这个函数很难梳理，比如有三个记录（10，15，20），SELECT id >= 10。典型的其流程：
    // 第一次调用 row_search_mvcc：
    //  1）pcur 通过定位到 rec=10（btr_pcur_open_with_no_init）
    //  2）store pcur（btr_pcur_store_position）
    // 第二次调用 row_search_mvcc：
    //  3）restore pcur。此时 pcur 指向的是记录 10
    //  4）goto next_rec
    //  5）goto rec_loop，此时 pcur 指向 15
    //  6）store pcur（btr_pcur_store_position）
    // 第三次调用 ......
     
    // 一般的，sel_restore_position_for_mysql 会重新把 pcur 恢复到之前同样的记录上，这样 need_to_process 为
    // false 表示这个记录已经被处理过了，就可以 goto next_rec
    if (!need_to_process)
      goto next_rec;
  // 注：以下两种情况都是首次放置 cursor。会获取 index latch
  else if (dtuple_get_n_fields(search_tuple) > 0)
    // 用于index scan
    // 尚未放置cursor，从顶至下遍历B+ Tree，根据search_tuple放置cursor
    btr_pcur_open_with_no_init()
  else
    // 用于 table scan
    // 尚未放置cursor，将cursor置于B+ Tree的一端
    btr_pcur_open_at_index_side()
 
rec_loop:
  if (page_rec_is_infimum)
    goto next_rec
   
  if (page_rec_is_supremum)
    goto next_rec;
 
  // 得到 cursor 指向的 record
  rec = btr_pcur_get_rec(pcur)
  // 如果是点查询，比较 rec 与 search_tuple（范围查询 match_mode 为0）
  if (match_mode == ...) {
    if (cmp_dtuple_rec() != 0)
      // 返回错误，record不存在
      err = DB_RECORD_NOT_FOUND;
      return;
  }
 
  // Step-2：根据需求对 record 加锁（lock），或者不需要锁（MVCC）
  if (prebuilt->select_lock_type != LOCK_NONE) {
    // 对 record 加 next-key lock 或 gap lock，防止幻读
  } else {
    // 根据不同的隔离级别，有不同的行为。
    // 1）隔离级别是 RU（read uncommitted），不做任何处理
    if (trx->isolation_level == TRX_ISO_READ_UNCOMMITTED)
    // 2）其他隔离级别，如果索引是聚簇索引，直接构建可见的数据行版本，得到 result_rec
    else if (index == clust_index)
      row_sel_build_prev_vers_for_mysql()
    // 3）如果不是聚簇索引，那么需要根据二级索引数据行再次在聚簇索引中查找，得到 result_rec
    else ...
  }
 
  // Step-3：根据 ICP （index condition pushdown），判断该记录行是否满足条件
  // 1）不满足（ICP_NO_MATCH），试图得到下一个 record（goto next_rec）
  // 2）满足（ICP_MATCH），返回给 MySQL 该记录行
  // 3）超出范围（ICP_OUT_OF_RANGE），goto idx_cond_failed
  row_search_idx_cond_check(buf, prebuilt, rec, offsets)
 
  // 必要的话，拿到主键索引的记录行（如果使用的是二级索引查询）
  row_sel_get_clust_rec_for_mysql
  // result_rec 是得到的满足可见性的聚簇索引数据行
  // 是否需要 prefetch 更多的记录行？或者直接转换成 MySQL 格式
  if (record_buffer != nullptr ...) {
    // 接下来实现"cache rows"优化，暂略
  } else {
    // 将 record 转换成 MySQL 格式
    row_sel_store_mysql_rec()
  }
     
  // 优化：使用 record buffer
  // 如果可以使用 record buffer（函数 can_prefetch_records）且 record buffer 未满，则把 record 缓存到
  // record buffer 里，然后 goto next_reocrd
  // 等到 record buffer 填满，从 record buffer 拿到最开始的 record，返回给 Server 层
  row_sel_enqueue_cache_row_for_mysql
  ...
  // 函数成功
  err = DB_SUCCESS;
   
idx_cond_failed:
  // Step-4：保存 cursor 的实时信息（如果是聚簇索引上的点查询则无需保存）并返回给 MySQL
  if (!unique_search || !dict_index_is_clust(index) || ...)
    btr_pcur_store_position()
 
  return;
 
next_rec:
  // Step-5：将 cursor 移动到顺序的下一个 record，或前一个 record
  if (mtr_has_extra_clust_latch) {
    // 如果cursor在二级索引中，那么需要先mtr_commit(mtr)，再mtr_start(mtr)
    // 这里需要注意cursor->rel_pos这个变量
    // 在每一次得到row，更新cursor，然后返回给
  }
  if (moves_up)
    // 移动到后一个 record，如果需要则移动到后一个数据页
    btr_pcur_move_to_next()
  else 
    // 移动到前一个 record，如果需要则移动到前一个数据页（e.g cursor在当前数据页的第一个record）
    // 需要 mtr_commit(mtr)，再 mtr_start(mtr)，因为 B-tree 并发控制机制要求 latch 持有顺序是由左至右
    btr_pcur_move_to_prev()
}

```