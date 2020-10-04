#1.row_ins_index_entry

入口函数在  row_ins

```cpp
row_ins_index_entry
  |- row_ins_clust_index_entry
    |- btr_cur_search_to_nth_level
    |- row_ins_clust_index_entry_by_modify
    |- btr_cur_optimistic_insert / btr_cur_pessimistic_insert
  |- row_ins_sec_index_entry
    |- btr_cur_search_to_nth_level
    // 1. 唯一键索引
    // 2. 普通二级索引
      |- row_ins_sec_index_entry_by_modify
      |- btr_cur_optimistic_insert / btr_cur_pessimistic_insert
      
```	