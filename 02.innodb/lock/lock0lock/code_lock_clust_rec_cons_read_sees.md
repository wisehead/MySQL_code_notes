#1.lock_clust_rec_cons_read_sees

```cpp

/*********************************************************************//**
Checks that a record is seen in a consistent read.  //在一个一致性读时，检查记录是否可见
@return true if sees, or false if an earlier version of the record should be retrieved */
bool
lock_clust_rec_cons_read_sees(
    const rec_t*    rec,      /*!< in: user record which should be read or passed
 over by a read cursor */
    dict_index_t*   index,    /*!< in: clustered index */
    const ulint*    offsets,  /*!< in: rec_get_offsets(rec, index) */
    ReadView*       view)     /*!< in: consistent read view */
//在指定的快照下，查看索引index上的rec记录是否可见
{...
    /* Temp-tables are not shared across connections and multiple transactions
 from different connections cannot
       simultaneously operate on same temp-table and so read of temp-table is
       always consistent read. */
    if (srv_read_only_mode || dict_table_is_temporary(index->table)) {
    //临时表属于某个会话，不能被其他会话操作，因而不存在不一致的问题
        ut_ad(view == 0 || dict_table_is_temporary(index->table));
        return(true);
    }
    /* NOTE that we call this function while holding the search system latch. */
    trx_id_t    trx_id = row_get_rec_trx_id(rec, index, offsets);
//获取索引上的记录上的事务ID，把此事务ID放到view快照内检查是否可见
    return(view->changes_visible(trx_id, index->table->name));
//把此事务ID放到view快照内检查是否可见
}
```