#1.struct trx_lock_t

```cpp
/*******************************************************************//**
Latching protocol for trx_lock_t::que_state.  trx_lock_t::que_state
captures the state of the query thread during the execution of a query.
This is different from a transaction state. The query state of a transaction
can be updated asynchronously by other threads.  The other threads can be
system threads, like the timeout monitor thread or user threads executing
other queries. Another thing to be mindful of is that there is a delay between
when a query thread is put into LOCK_WAIT state and before it actually starts
waiting.  Between these two events it is possible that the query thread is
granted the lock it was waiting for, which implies that the state can be changed
asynchronously.

All these operations take place within the context of locking. Therefore state
changes within the locking code must acquire both the lock mutex and the
trx->mutex when changing trx->lock.que_state to TRX_QUE_LOCK_WAIT or
trx->lock.wait_lock to non-NULL but when the lock wait ends it is sufficient
to only acquire the trx->mutex.
To query the state either of the mutexes is sufficient within the locking
code and no mutex is required when the query thread is no longer waiting. */

/** The locks and state of an active transaction. Protected by
lock_sys->mutex, trx->mutex or both. */
struct trx_lock_t {
    ulint       n_active_thrs;  /*!< number of active query threads */

    trx_que_t   que_state;  /*!< valid when trx->state
                    == TRX_STATE_ACTIVE: TRX_QUE_RUNNING,
                    TRX_QUE_LOCK_WAIT, ... */

    lock_t*     wait_lock;  /*!< if trx execution state is
                    TRX_QUE_LOCK_WAIT, this points to
                    the lock request, otherwise this is
                    NULL; set to non-NULL when holding
                    both trx->mutex and lock_sys->mutex;
                    set to NULL when holding
                    lock_sys->mutex; readers should
                    hold lock_sys->mutex, except when
                    they are holding trx->mutex and
                    wait_lock==NULL */
    ib_uint64_t deadlock_mark;  /*!< A mark field that is initialized
                    to and checked against lock_mark_counter
                    by lock_deadlock_recursive(). */
    bool        was_chosen_as_deadlock_victim;
                    /*!< when the transaction decides to
                    wait for a lock, it sets this to false;
                    if another transaction chooses this
                    transaction as a victim in deadlock
                    resolution, it sets this to true.
                    Protected by trx->mutex. */
    time_t      wait_started;   /*!< lock wait started at this time,
                    protected only by lock_sys->mutex */

    que_thr_t*  wait_thr;   /*!< query thread belonging to this
                    trx that is in QUE_THR_LOCK_WAIT
                    state. For threads suspended in a
                    lock wait, this is protected by
                    lock_sys->mutex. Otherwise, this may
                    only be modified by the thread that is
                    serving the running transaction. */

    lock_pool_t     rec_pool;       /*!< Pre-allocated record locks */

    lock_pool_t     table_pool;     /*!< Pre-allocated table locks */

    ulint           rec_cached;     /*!< Next free lock in pool */

    ulint           table_cached;   /*!< Next free table lock in pool */

    mem_heap_t* lock_heap;  /*!< memory heap for trx_locks;
                    protected by lock_sys->mutex */

    UT_LIST_BASE_NODE_T(lock_t)
            trx_locks;  /*!< locks requested
                    by the transaction;
                    insertions are protected by trx->mutex
                    and lock_sys->mutex; removals are
                    protected by lock_sys->mutex */

    ib_vector_t*    table_locks;    /*!< All table locks requested by this
                    transaction, including AUTOINC locks */

    bool        cancel;     /*!< true if the transaction is being
                    rolled back either via deadlock
                    detection or due to lock timeout. The
                    caller has to acquire the trx_t::mutex
                    in order to cancel the locks. In
                    lock_trx_table_locks_remove() we
                    check for this cancel of a transaction's
                    locks and avoid reacquiring the trx
                    mutex to prevent recursive deadlocks.
                    Protected by both the lock sys mutex
                    and the trx_t::mutex. */
};                    

```