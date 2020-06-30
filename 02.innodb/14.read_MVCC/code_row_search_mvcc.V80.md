#1.row_search_mvcc

```cpp
row_search_mvcc
  // 1. 首次放置 cursor 到某个 record（index scan）
  |- btr_pcur_open_with_no_init
  // 2. 首次放置 cursor 到 B-tree 的一端（table scan）
  |- btr_pcur_open_at_index_side
  // 3. 重置 cursor 到之前保存的位置
  |- sel_restore_position_for_mysql
    |- btr_pcur_restore_position
      // 1）如果 B-tree 是空的（m_rel_pos == BTR_PCUR_AFTER_LAST_IN_TREE ||
      //   m_rel_pos == BTR_PCUR_BEFORE_FIRST_IN_TREE） 直接把 cursor 置于 B-tree 一端
      |- btr_cur_open_at_index_side
        // page 是否在活跃的 mtr 之中？设置 mtr.retry = true
        |- buf_page_get
      // 2）乐观策略：认为 cursor 指向的位置仍然合法（e.g record 依然存在）
      |- btr_cur_optimistic_latch_leaves
        // page 是否在活跃的 mtr 之中？设置 mtr.retry = true
        |- buf_page_get
      // 3）悲观策略：需要一次重新检索
      |- open_no_init
        |- btr_cur_search_to_nth_level
          // page 是否在活跃的 mtr 之中？
          |- buf_page_get
    // 这里是很难看懂的地方，叫 "adjust position"
    |- btr_pcur_move_to_next / btr_pcur_move_to_prev
      // page 是否在活跃的 mtr 之中？设置 mtr.retry = true
      |- buf_page_get_gen
   
  ...
   
  // 4. 移动 cursor（正向/反向）
  |- btr_pcur_move_to_next / btr_pcur_move_to_prev
    // page 是否在活跃的 mtr 之中？设置 mtr.retry = true
    |- buf_page_get_gen
```