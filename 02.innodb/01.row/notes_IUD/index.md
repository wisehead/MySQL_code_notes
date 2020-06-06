
# [InnoDB（十二）：IUD]

IUD 是 INSERT / UPDATE / DELETE 的合称，是数据库提供的三个基本操作。我们逐一描述它们在 InnoDB 的实现

## INSERT

入口函数在  row\_ins

```plain
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

### 自增键（autoinc）crash safe

autoinc 此前一直不是 crash safe（[Bug #199 Innodb autoincrement stats los on restart](https://bugs.mysql.com/bug.php?id=199)），即 table 的 autoinc 并没有持久化，所以 crash 再重启后可能会观察到 autoinc 重复

在 MySQL 8.0 里通过 [WL#7816: InnoDB: Persist the corrupted flag in the data dictionary](https://dev.mysql.com/worklog/task/?id=7816) （**这篇 Worklog 里有很细致的描述**）将动态元信息（autoinc 是其中之一）持久化。具体思想是：

1.  一旦 table X 的 autoinc 更新，记录一条新的 redo record（MLOG\_TABLE\_DYNAMIC\_META）
2.  在 checkpoint 时将 X 目前最新的 autoinc 值（dict\_table\_t→ autoinc）记录到 Table buffer （一张只属于 InnoDB 的表，mysql.innodb\_dynamic\_metadata）中（dict\_persist\_to\_dd\_table\_buffer）
3.  在 crash recovery 时，前滚过程中将 MLOG\_TABLE\_DYNAMIC\_META 收集起来到一个 map（metadata\_recover->m\_tables）中。前滚结束后再恢复数据字典（包括 autoinc，函数 srv\_dict\_recovery\_on\_restart）时会把收集到的 MLOG\_TABLE\_DYNAMIC\_META 回放掉

但我们要注意 MLOG\_TABLE\_DYNAMIC\_META record 使用的是与用户事务相同的 mtr。这就意味着可能出现：

1.  目前 table X autoinc 到 2
2.  开启事务 T1 执行 INSERT，使 autoinc 到达 3，生成 INSERT record（R1），MLOG\_TABLE\_DYNAMIC\_META record（R2）
3.  尚未做 checkpoint 数据库 crash ... 重启后执行 crash recovery 前滚 R1，收集 R2
4.  恢复数据字典时把 table X autoinc 更新至 3
5.  事务 T 被回滚，table X 的记录 autoinc 只到 2
6.  开启事务 T2 执行 INSERT，autoinc 为 4。出现 autoinc 不连续 …

      ![](assets/1591425012-c23dae5a4df118a71b6d9ba27f30f250.png)

## UPDATE  / DALETE

入口函数在 row\_upd

```plain
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
    |- btr_cur_update_in_place   // 属性列长度未变化：INPLACE 的方式
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

（未完待续）

## 参考

*   [MySQL · 引擎特性 · 动态元信息持久化](http://mysql.taobao.org/monthly/2019/12/01/)


