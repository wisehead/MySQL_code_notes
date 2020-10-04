#1.btr_cur_optimistic_insert

```cpp
row_ins_clust_index_entry_low
  // 查找 record，以 PAGE_CUR_LE 模式（<=），即 curosr 指向最后一个主键小于待插入值的 record 的位置（下图中的id=3）
  // 详细见上文函数 page_cur_search_with_match 的分析
  |- btr_cur_search_to_nth_level
  |- btr_cur_optimistic_insert
    |- page_cur_tuple_insert
      |- page_cur_insert_rec_low
        // 从自由空间链表或未分配空间区域分配空间
        |- page_mem_alloc_heap / page_header_get_ptr(page, PAGE_FREE)
        // Insert the record in the linked list of records
        |- ......
        // 记录此次 INSERT 的 redo 日志
        |- page_cur_insert_rec_write_log
```