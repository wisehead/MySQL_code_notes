#1. row_upd

InnoDB 入口函数在 row_upd

```cpp
// UPDATE OR DELETE 主键索引
row_upd_clust_step
  // 如果在执行 DELETE SQL，将 record 标记为 delete mark
  |- row_upd_del_mark_clust_rec
  // 以不同的方式执行UPDATE
  // 1. 修改主键
  |- row_upd_clust_rec_by_insert // DELETE MARK + INSERT 的方式
    |- btr_cur_del_mark_set_clust_rec // 将 record 标记为 delete mark
    |- mtr_commit(mtr); // 这里会提交 mtr
    |- row_ins_clust_index_entry // 插入新的 record
  // 2. 未修改主键（不会将 record 标记为 delete mark）
  |- row_upd_clust_rec
    |- btr_cur_update_in_place   // 属性列长度未变化：INPLACE 的方式
    |- btr_cur_optimistic_update // 属性列长度有变化：DELETE + INSERT 的方式（注意，不是 DELETE MARK）
      |- page_cur_delete_rec // （物理上）删除 record
      |- btr_cur_insert_if_possible // 插入新的 record
 
// UPDATE OR DELETE 二级索引
row_upd_sec_step
  // 如果在执行 DELETE SQL，将 record 标记为 delete mark
  |- btr_cur_del_mark_set_sec_rec
  // 如果在执行 UPDATE，DELETE MARK + INSERT 的方式
  |- row_ins_sec_index_entry
  
```