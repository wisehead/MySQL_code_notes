#1.sel_set_rec_lock

```cpp
sel_set_rec_lock( //Sets a lock on a record.此函数是在记录上设置锁的入口，对于所要施加的
			//锁，用mode和type两个参数来标识（体会分开的用意和这些参数被赋值的情况）
    btr_pcur_t*   pcur,    /*!< in: cursor */
    const rec_t*  rec,     /*!< in: record */  //记录
    dict_index_t* index,   /*!< in: index */
    const ulint*  offsets, /*!< in: rec_get_offsets(rec, index) */
    ulint         mode,    /*!< in: lock mode *///加锁的mode，即本书称为粒度，如X锁、S锁等
    ulint         type, /*!< in: LOCK_ORDINARY, LOCK_GAP, or LOC_REC_NOT_GAP */
    //加锁的type，即本书称为种类，如LOCK_GAP等
    que_thr_t*    thr,  /*!< in: query thread */
    mtr_t*        mtr)  /*!< in: mtr */

```

#2.caller

```cpp
row_sel(  //执行一个SELECT查询
    sel_node_t*    node,    /*!< in: select node */
    que_thr_t*     thr)     /*!< in: query thread */
{...
            if (srv_locks_unsafe_for_binlog
                || trx->isolation_level<= TRX_ISO_READ_COMMITTED) {
//对于不同隔离级别，lock_type的值不同
                if (page_rec_is_supremum(next_rec)) {
                    goto skip_lock;
                }
                lock_type = LOCK_REC_NOT_GAP;
            } else {
                lock_type = LOCK_ORDINARY;
            }
            err = sel_set_rec_lock(&plan->pcur,next_rec, index, offsets,
            node->row_lock_mode,lock_type, thr, &mtr);
...}
```