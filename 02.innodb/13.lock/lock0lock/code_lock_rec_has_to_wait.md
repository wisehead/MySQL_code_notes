#1.lock_rec_has_to_wait

```cpp

/*********************************************************************//**
Checks if a lock request for a new lock has to wait for request lock2.
@return TRUE if new lock has to wait for lock2 to be removed */
UNIV_INLINE
ibool
lock_rec_has_to_wait(
    const trx_t*    trx,    /*!< in: trx of new lock */  //准备申请锁的事务
    ulint        type_mode,/*!< in: precise mode of the new lockto set: LOCK_S or LOCK_X,
                                    possiblyORed to LOCK_GAP or LOCK_REC_NOT_
GAP,LOCK_INSERT_INTENTION */
    const lock_t*   lock2,    /*!< in: another record lock; NOTE thatit is
    assumed that this has a lock bit  //已经分配的锁
                                       set on the same record as in the newlock
we are setting */
    bool        lock_is_on_supremum)/*!< in: TRUE if we are setting thelock on
the 'supremum' record of anindex page:
                                             we know then that the lockrequest is
really for a 'gap' type lock */
{...
    if (trx != lock2->trx    //不是同一个事务。如果是同一个事务，则返回FALSE表明不存在冲突
         && !lock_mode_compatible(static_cast<lock_mode>(
         //不相容，即存在冲突；不同事务但锁相容，则则返回FALSE表明不存在冲突
                         LOCK_MODE_MASK & type_mode), lock_get_mode(lock2))) {
        /* We have somewhat complex rules when gap type record lockscause waits */
        //如下四条规则，放宽了限制，使得冲突减少。注意，这是提高并发度的方法
        if ((lock_is_on_supremum || (type_mode &LOCK_GAP))
        //规则1:申请锁者申请GAP锁，不是插入操作，则锁不冲突不需要等待
                && !(type_mode &LOCK_INSERT_INTENTION)) {
            /* Gap type locks without LOCK_INSERT_INTENTION flagdo not need to
              wait for anything.
              This is because different users can have conflicting lock typeson gaps. */
                //这说明GAP上允许并发加锁
              return(FALSE);
        }
        if (!(type_mode &LOCK_INSERT_INTENTION) //规则2: 不是插入操作，且持锁者带有GAP
                                                  锁，则锁不冲突不需要等待
               && lock_rec_get_gap(lock2)) {
            /* Record lock (LOCK_ORDINARY or LOCK_REC_NOT_GAPdoes not need to
               wait for a gap type lock */
            return(FALSE);
        }
        if ((type_mode & LOCK_GAP) //规则3:申请锁者申请GAP锁，而持锁者不持有GAP锁，则锁
                                     不冲突不需要等待
               && lock_rec_get_rec_not_gap(lock2)) {
            /* Lock on gap does not need to wait fora LOCK_REC_NOT_GAP type lock */
            return(FALSE);
        }
        if (lock_rec_get_insert_intention(lock2)) { //规则4: 持锁者持有插入意向锁，不阻塞任何锁
            return(FALSE);
        }
        return(TRUE);
    }
    return(FALSE);
}

```