#1.struct dict_table_t

```cpp
/** Data structure for a database table.  Most fields will be
initialized to 0, NULL or FALSE in dict_mem_table_create(). */
struct dict_table_t{


    table_id_t  id; /*!< id of the table */
    mem_heap_t* heap;   /*!< memory heap */
    char*       name;   /*!< table name */
    const char* dir_path_of_temp_table;/*!< NULL or the directory path
                where a TEMPORARY table that was explicitly
                created by a user should be placed if
                innodb_file_per_table is defined in my.cnf;
                in Unix this is usually /tmp/..., in Windows
                temp\... */
    char*       data_dir_path; /*!< NULL or the directory path
                specified by DATA DIRECTORY */
    unsigned    space:32;
                /*!< space where the clustered index of the
                table is placed */
    unsigned    flags:DICT_TF_BITS; /*!< DICT_TF_... */
    unsigned    flags2:DICT_TF2_BITS;   /*!< DICT_TF2_... */
    unsigned    ibd_file_missing:1;
                /*!< TRUE if this is in a single-table
                tablespace and the .ibd file is missing; then
                we must return in ha_innodb.cc an error if the
                user tries to query such an orphaned table */
    unsigned    cached:1;/*!< TRUE if the table object has been added
                to the dictionary cache */
    unsigned    to_be_dropped:1;
                /*!< TRUE if the table is to be dropped, but
                not yet actually dropped (could in the bk
                drop list); It is turned on at the beginning
                of row_drop_table_for_mysql() and turned off
                just before we start to update system tables
                for the drop. It is protected by
                dict_operation_lock */
    unsigned    n_def:10;/*!< number of columns defined so far */
    unsigned    n_cols:10;/*!< number of columns */
    unsigned    can_be_evicted:1;
                /*!< TRUE if it's not an InnoDB system table
                or a table that has no FK relationships */
    unsigned    corrupted:1;
                /*!< TRUE if table is corrupted */
    unsigned    drop_aborted:1;
                /*!< TRUE if some indexes should be dropped
                after ONLINE_INDEX_ABORTED
                or ONLINE_INDEX_ABORTED_DROPPED */
    dict_col_t* cols;   /*!< array of column descriptions */
    const char* col_names;
                /*!< Column names packed in a character string
                "name1\0name2\0...nameN\0".  Until
                the string contains n_cols, it will be
                allocated from a temporary heap.  The final
                string will be allocated from table->heap. */
#ifndef UNIV_HOTBACKUP
    hash_node_t name_hash; /*!< hash chain node */
    hash_node_t id_hash; /*!< hash chain node */
    UT_LIST_BASE_NODE_T(dict_index_t)
            indexes; /*!< list of indexes of the table */

    dict_foreign_set    foreign_set;
                /*!< set of foreign key constraints
                in the table; these refer to columns
                in other tables */

    dict_foreign_set    referenced_set;
                /*!< list of foreign key constraints
                which refer to this table */

    UT_LIST_NODE_T(dict_table_t)
            table_LRU; /*!< node of the LRU list of tables */
    unsigned    fk_max_recusive_level:8;
                /*!< maximum recursive level we support when
                loading tables chained together with FK
                constraints. If exceeds this level, we will
                stop loading child table into memory along with
                its parent table */
    ulint       n_foreign_key_checks_running;
                /*!< count of how many foreign key check
                operations are currently being performed
                on the table: we cannot drop the table while
                there are foreign key checks running on
                it! */
    trx_id_t    def_trx_id;
                /*!< transaction id that last touched
                the table definition, either when
                loading the definition or CREATE
                TABLE, or ALTER TABLE (prepare,
                commit, and rollback phases) */
    trx_id_t    query_cache_inv_id;
                /*!< Transactions whose view low limit is greater than
                this number are not allowed to store to the MySQL query cache
                or retrieve from it. When a trx with undo logs commits,
                it sets this to the value of the trx id counter for
                the tables it had an IX lock on  */

#ifdef UNIV_DEBUG
    /*----------------------*/
    ibool       does_not_fit_in_memory;
                /*!< this field is used to specify in
                simulations tables which are so big
                that disk should be accessed: disk
                access is simulated by putting the
                thread to sleep for a while; NOTE that
                this flag is not stored to the data
                dictionary on disk, and the database
                will forget about value TRUE if it has
                to reload the table definition from
                disk */
#endif /* UNIV_DEBUG */
    /*----------------------*/
    unsigned    big_rows:1;
                /*!< flag: TRUE if the maximum length of
                a single row exceeds BIG_ROW_SIZE;
                initialized in dict_table_add_to_cache() */
                /** Statistics for query optimization */
                /* @{ */

    volatile os_once::state_t   stats_latch_created;
                /*!< Creation state of 'stats_latch'. */

    rw_lock_t*  stats_latch; /*!< this latch protects:
                dict_table_t::stat_initialized
                dict_table_t::stat_n_rows (*)
                dict_table_t::stat_clustered_index_size
                dict_table_t::stat_sum_of_other_index_sizes
                dict_table_t::stat_modified_counter (*)
                dict_table_t::indexes*::stat_n_diff_key_vals[]
                dict_table_t::indexes*::stat_index_size
                dict_table_t::indexes*::stat_n_leaf_pages
                (*) those are not always protected for
                performance reasons */
    unsigned    stat_initialized:1; /*!< TRUE if statistics have
                been calculated the first time
                after database startup or table creation */
#define DICT_TABLE_IN_USED      -1
    lint        memcached_sync_count;
                /*!< count of how many handles are opened
                to this table from memcached; DDL on the
                table is NOT allowed until this count
                goes to zero. If it's -1, means there's DDL
                        on the table, DML from memcached will be
                blocked. */
    ib_time_t   stats_last_recalc;
                /*!< Timestamp of last recalc of the stats */
    ib_uint32_t stat_persistent;
                /*!< The two bits below are set in the
                ::stat_persistent member and have the following
                meaning:
                1. _ON=0, _OFF=0, no explicit persistent stats
                setting for this table, the value of the global
                srv_stats_persistent is used to determine
                whether the table has persistent stats enabled
                or not
                2. _ON=0, _OFF=1, persistent stats are
                explicitly disabled for this table, regardless
                of the value of the global srv_stats_persistent
                3. _ON=1, _OFF=0, persistent stats are
                explicitly enabled for this table, regardless
                of the value of the global srv_stats_persistent
                4. _ON=1, _OFF=1, not allowed, we assert if
                this ever happens. */
#define DICT_STATS_PERSISTENT_ON    (1 << 1)
#define DICT_STATS_PERSISTENT_OFF   (1 << 2)
    ib_uint32_t stats_auto_recalc;
                /*!< The two bits below are set in the
                ::stats_auto_recalc member and have
                the following meaning:
                1. _ON=0, _OFF=0, no explicit auto recalc
                setting for this table, the value of the global
                srv_stats_persistent_auto_recalc is used to
                determine whether the table has auto recalc
                enabled or not
                2. _ON=0, _OFF=1, auto recalc is explicitly
                disabled for this table, regardless of the
                value of the global
                srv_stats_persistent_auto_recalc
                3. _ON=1, _OFF=0, auto recalc is explicitly
                enabled for this table, regardless of the
                value of the global
                srv_stats_persistent_auto_recalc
                4. _ON=1, _OFF=1, not allowed, we assert if
                this ever happens. */
#define DICT_STATS_AUTO_RECALC_ON   (1 << 1)
#define DICT_STATS_AUTO_RECALC_OFF  (1 << 2)
    ulint       stats_sample_pages;
                /*!< the number of pages to sample for this
                table during persistent stats estimation;
                if this is 0, then the value of the global
                srv_stats_persistent_sample_pages will be
                used instead. */
    ib_uint64_t stat_n_rows;
                /*!< approximate number of rows in the table;
                we periodically calculate new estimates */
    ulint       stat_clustered_index_size;
                /*!< approximate clustered index size in
                database pages */
    ulint       stat_sum_of_other_index_sizes;
                /*!< other indexes in database pages */
    ib_uint64_t stat_modified_counter;
                /*!< when a row is inserted, updated,
                or deleted,
                we add 1 to this number; we calculate new
                estimates for the stat_... values for the
                table and the indexes when about 1 / 16 of
                table has been modified;
                also when the estimate operation is
                called for MySQL SHOW TABLE STATUS; the
                counter is reset to zero at statistics
                calculation; this counter is not protected by
                any latch, because this is only used for
                heuristics */
#define BG_STAT_NONE        0
#define BG_STAT_IN_PROGRESS (1 << 0)
                /*!< BG_STAT_IN_PROGRESS is set in
                stats_bg_flag when the background
                stats code is working on this table. The DROP
                TABLE code waits for this to be cleared
                before proceeding. */
#define BG_STAT_SHOULD_QUIT (1 << 1)
                /*!< BG_STAT_SHOULD_QUIT is set in
                stats_bg_flag when DROP TABLE starts
                waiting on BG_STAT_IN_PROGRESS to be cleared,
                the background stats thread will detect this
                and will eventually quit sooner */
    byte        stats_bg_flag;
                /*!< see BG_STAT_* above.
                Writes are covered by dict_sys->mutex.
                Dirty reads are possible. */
                /* @} */
    /*----------------------*/
                /**!< The following fields are used by the
                AUTOINC code.  The actual collection of
                tables locked during AUTOINC read/write is
                kept in trx_t. In order to quickly determine
                whether a transaction has locked the AUTOINC
                lock we keep a pointer to the transaction
                here in the autoinc_trx variable. This is to
                avoid acquiring the lock_sys_t::mutex and
                scanning the vector in trx_t.

                When an AUTOINC lock has to wait, the
                corresponding lock instance is created on
                the trx lock heap rather than use the
                pre-allocated instance in autoinc_lock below.*/
                /* @{ */
    lock_t*     autoinc_lock;
                /*!< a buffer for an AUTOINC lock
                for this table: we allocate the memory here
                so that individual transactions can get it
                and release it without a need to allocate
                space from the lock heap of the trx:
                otherwise the lock heap would grow rapidly
                if we do a large insert from a select */
    ib_mutex_t      autoinc_mutex;
                /*!< mutex protecting the autoincrement
                counter */
    ib_uint64_t autoinc;/*!< autoinc counter value to give to the
                next inserted row */
    ulong       n_waiting_or_granted_auto_inc_locks;
                /*!< This counter is used to track the number
                of granted and pending autoinc locks on this
                table. This value is set after acquiring the
                lock_sys_t::mutex but we peek the contents to
                determine whether other transactions have
                acquired the AUTOINC lock or not. Of course
                only one transaction can be granted the
                lock but there can be multiple waiters. */
    const trx_t*    autoinc_trx;
                /*!< The transaction that currently holds the
                the AUTOINC lock on this table.
                Protected by lock_sys->mutex. */
    fts_t*      fts;    /* FTS specific state variables */
                /* @} */
    /*----------------------*/

    ib_quiesce_t     quiesce;/*!< Quiescing states, protected by the
                dict_index_t::lock. ie. we can only change
                the state if we acquire all the latches
                (dict_index_t::lock) in X mode of this table's
                indexes. */

    /*----------------------*/
    ulint       n_rec_locks;
                /*!< Count of the number of record locks on
                this table. We use this to determine whether
                we can evict the table from the dictionary
                cache. It is protected by lock_sys->mutex. */
    ulint       n_ref_count;
                /*!< count of how many handles are opened
                to this table; dropping of the table is
                NOT allowed until this count gets to zero;
                MySQL does NOT itself check the number of
                open handles at drop */
    UT_LIST_BASE_NODE_T(lock_t)
            locks;  /*!< list of locks on the table; protected
                by lock_sys->mutex */
#endif /* !UNIV_HOTBACKUP */
#ifdef UNIV_DEBUG
    ulint       magic_n;/*!< magic number */
/** Value of dict_table_t::magic_n */
# define DICT_TABLE_MAGIC_N 76333786
#endif /* UNIV_DEBUG */
};                      
```

