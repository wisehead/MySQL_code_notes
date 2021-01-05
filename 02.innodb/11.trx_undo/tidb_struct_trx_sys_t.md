#1.struct trx_sys_t

```cpp
/** The transaction system central memory data structure. */
struct trx_sys_t {

    char        pad1[64];   /*!< To avoid false sharing */
    TrxSysMutex mutex;      /*!< mutex protecting most fields in
                    this structure except when noted
                    otherwise */

    char        pad2[64];   /*!< To avoid false sharing */
    ReadViewMutex   read_view_mutex;/*!< mutex protecting max_trx_id, mvcc
                      refernce */

    char        pad3[64];   /*!< To avoid false sharing */
    TrxSysMutex ids_mutex;  /*!< mutex protecting the ids vector below
                    used by log applying thread in the slave */

    TrxSysMutex flush_mutex;    /*!< mutex protecting the operation of
                    the ids flushing in the slave node */

    trx_ids_t   trx_end_ids;    /*!< Array of the end transaction IDs
                    for log applying thread. Note that the
                    array does not guarantee the order of
                    the trx ids, so make sure that sort them
                    before using */

    char        pad4[64];   /*!< To avoid false sharing */

    RwTrxMutex  rw_trx_mutex[RW_TRX_PARTITION_INSTANCE];
                    /*!< mutex protecting rw_trx_sets*/

    MVCC*       mvcc;       /*!< Multi version concurrency control
                    manager */
    volatile trx_id_t
            max_trx_id; /*!< The smallest number not yet
                    assigned as a transaction id or
                    transaction number. This is declared
                    volatile because it can be accessed
                    without holding any mutex during
                    AC-NL-RO view creation. */
    trx_ut_list_t   serialisation_list;
                    /*!< Ordered on trx_t::no of all the
                    currenrtly active RW transactions */
#ifdef UNIV_DEBUG
    trx_id_t    rw_max_trx_id;  /*!< Max trx id of read-write
                    transactions which exist or existed */
#endif /* UNIV_DEBUG */

    char        pad5[64];   /*!< To avoid false sharing */
    trx_ut_list_t   rw_trx_list;    /*!< List of active and committed in
                    memory read-write transactions, sorted
                    on trx id, biggest first. Recovered
                    transactions are always on this list. */

    char        pad6[64];   /*!< To avoid false sharing */
    trx_ut_list_t   mysql_trx_list; /*!< List of transactions created
                    for MySQL. All user transactions are
                    on mysql_trx_list. The rw_trx_list
                    can contain system transactions and
                    recovered transactions that will not
                    be in the mysql_trx_list.
                    mysql_trx_list may additionally contain
                    transactions that have not yet been
                    started in InnoDB. */

    char        pad7[64];   /*!< To avoid false sharing */
    trx_ids_t   rw_trx_ids; /*!< Array of Read write transaction IDs
                    for MVCC snapshot. A ReadView would take
                    a snapshot of these transactions whose
                    changes are not visible to it. We should
                    remove transactions from the list before
                    committing in memory and releasing locks
                    to ensure right order of removal and
                    consistent snapshot. */

    trx_ids_set_t   slave_trx_ids_set;  /*!< Set of the rw_ids in
                        the slave*/

    char        pad8[64];   /*!< To avoid false sharing */
    trx_rseg_t* rseg_array[TRX_SYS_N_RSEGS];
                    /*!< Pointer array to rollback
                    segments; NULL if slot not in use;
                    created and destroyed in
                    single-threaded mode; not protected
                    by any mutex, because it is read-only
                    during multi-threaded operation */
    ulint       rseg_history_len;
                    /*!< Length of the TRX_RSEG_HISTORY
                    list (update undo logs for committed
                    transactions), protected by
                    rseg->mutex */

    trx_rseg_t* const pending_purge_rseg_array[TRX_SYS_N_RSEGS];
                    /*!< Pointer array to rollback segments
                    between slot-1..slot-srv_tmp_undo_logs
                    that are now replaced by non-redo
                    rollback segments. We need them for
                    scheduling purge if any of the rollback
                    segment has pending records to purge. */

    TrxIdSet    rw_trx_sets[RW_TRX_PARTITION_INSTANCE];
                    /*!< Instead of storing trx_id and trx in rw_trx
                      set, we store mapping information in rw_trx_sets
                      according trx->id. */

    ulint       n_prepared_trx; /*!< Number of transactions currently
                    in the XA PREPARED state */

    ulint       n_prepared_recovered_trx; /*!< Number of transactions
                    currently in XA PREPARED state that are
                    also recovered. Such transactions cannot
                    be added during runtime. They can only
                    occur after recovery if mysqld crashed
                    while there were XA PREPARED
                    transactions. We disable query cache
                    if such transactions exist. */

    ulint       n_need_recovered_xa; /*!< Number of transactions
                    currently in XA PREPARED state that are
                    also recovered just during the system
                    startup. */

    trx_id_t    max_trx_no; /*!< Max trx no in the master mode,
                    proceted by read_view mutex */

    trx_id_t    max_trans_no;   /*!< The trx no which has been logged
                    and transferred to the slave node,
                    protected by read_view mutex */

    trx_id_t    low_no_login;   /*!< The trx no which an ongoing slave
                    login used and protected by the trx_sys
                    read view mutex */

    trx_id_t    slave_clean_id; /*!< trx id for clear the old id in the
                    slave node, protected by ids_mutex */
    trx_id_t    slave_low_limit_no;
                    /*!< Max trx no from MLOG_TRX_COMMIT,
                    update at each MLOG_TRX_COMMIT applied */

    trx_id_t    slave_dyn_low_limit_no;
                    /*!< It carries the the dynamic value
                    of the minimum trx no from the commit
                    log */

    trx_id_t    slave_max_trx_id;
                    /*!< It carries the the dynamic value
                    of the maximum trx no from the commit
                    log */

    trx_ids_set_t   slave_trx_init_ids;
                    /*!< Array of the initial transaction
                    IDs for the slave node, protected by
                    flush_mutex */
};                        
```