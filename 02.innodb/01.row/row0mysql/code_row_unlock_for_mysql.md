#1.row_unlock_for_mysql

```cpp
/** This can only be used when srv_locks_unsafe_for_binlog is TRUE or this
session is using a READ COMMITTED or READ UNCOMMITTED isolation level.
Before calling this function row_search_for_mysql() must have initialized
prebuilt->new_rec_locks to store the information which new
record locks really were set. This function removes a newly set clustered index
record lock under prebuilt->pcur or
prebuilt->clust_pcur.  Thus, this implements a 'mini-rollback' that releases the
 latest clustered index record lock we set.
@param[in,out]    prebuilt               prebuilt struct in MySQL handle
@param[in]        has_latches_on_recs    TRUE if called so that we have the
latches on the records under pcur
                                               and clust_pcur, and we do not need
 to reposition the cursors. */
void
row_unlock_for_mysql(row_prebuilt_t* prebuilt, ibool has_latches_on_recs)
{...
    if (prebuilt->new_rec_locks >= 1) {
...
        /* If the record has been modified by this transaction, do not unlock it. */
        if (index->trx_id_offset) {
         //如果是被本事务修改，则不释放锁（修改元组则会写事务ID到元组中）
            rec_trx_id = trx_read_trx_id(rec + index->trx_id_offset);
            //获得元组上的事务id值
        } else {...
            offsets = rec_get_offsets(rec, index, offsets, ULINT_UNDEFINED, &heap);
            rec_trx_id = row_get_rec_trx_id(rec, index, offsets);
      //获得元组上的事务id值
            if (UNIV_LIKELY_NULL(heap)) {
                mem_heap_free(heap);
            }
        }
        if (rec_trx_id != trx->id) {
        //元组上的事务id不是本事务的id，表明元组是被其他事务修改，释放锁
            /* We did not update the record: unlock it */
            rec = btr_pcur_get_rec(pcur);
            lock_rec_unlock(trx, btr_pcur_get_block(pcur), rec, static_cast<enum
            lock_mode>(prebuilt->select_lock_type));
            if (prebuilt->new_rec_locks >= 2) {  //new_rec_lock通常是0，如果隔离级别
            是READ COMMITTED或READ UNCOMMITTED
                rec = btr_pcur_get_rec(clust_pcur);  //则在row_search_mvcc()中获得
                记录锁后设置为2，所以需要对应解锁
                lock_rec_unlock(trx, btr_pcur_get_block(clust_pcur), rec, static_
                cast<enum lock_mode>(prebuilt->select_lock_type));
            }
        }
no_unlock:
        mtr_commit(&mtr);
    }
...
}

```