#1.struct trx_sys_t

```cpp
/** The transaction system central memory data structure. */
struct trx_sys_t{

    ib_mutex_t      mutex;      /*!< mutex protecting most fields in
                    this structure except when noted
                    otherwise */
    MVCC*           mvcc;       /*!< Multi version concurrency control
                    manager */
    volatile trx_id_t  max_trx_id;     /*!< The smallest number not yet
                    assigned as a transaction id or
                    transaction number. This is declared
                    volatile because it can be accessed
                    without holding any mutex during
                    AC-NL-RO view creation. */
    trx_list_t      serialisation_list;
                    /*!< Ordered on trx_t::no of all the
                    currenrtly active RW transactions */
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
#ifdef UNIV_DEBUG
    trx_id_t    rw_max_trx_id;  /*!< Max trx id of read-write transactions
                    which exist or existed */
#endif
    char            pad1[64];    /*!< To avoid false sharing */
    trx_list_t  rw_trx_list;    /*!< List of active and committed in
                    memory read-write transactions, sorted
                    on trx id, biggest first. Recovered
                    transactions are always on this list. */
    char            pad2[64];    /*!< To avoid false sharing */
    trx_list_t  mysql_trx_list; /*!< List of transactions created
                    for MySQL. All user transactions are
                    on mysql_trx_list. The rw_trx_list
                    can contain system transactions and
                    recovered transactions that will not
                    be in the mysql_trx_list.
                    mysql_trx_list may additionally contain
                    transactions that have not yet been
                    started in InnoDB. */
    trx_ids_t       rw_trx_ids;     /*!< Read write transaction IDs */

    char            pad3[64];     /*!< To avoid false sharing */
    trx_rseg_t* const rseg_array[TRX_SYS_N_RSEGS];
                    /*!< Pointer array to rollback
                    segments; NULL if slot not in use;
                    created and destroyed in
                    single-threaded mode; not protected
                    by any mutex, because it is read-only
                    during multi-threaded operation */
    ulint       rseg_history_len;/*!< Length of the TRX_RSEG_HISTORY
                    list (update undo logs for committed
                    transactions), protected by
                    rseg->mutex */
    TrxIdSet        rw_trx_set;     /*!< Mapping from transaction id
                                      to transaction instance */

};    

```