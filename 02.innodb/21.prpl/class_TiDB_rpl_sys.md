#1.class TiDB_rpl_sys

```cpp
/** tidb replication system struct for redo log receive & scan & apply
on slave.*/
class tidb_rpl_sys
{
public:
    class sync_info
    {
        /* The lsn what we record a timestamp for */
        atomic_lsn_t    m_sync_lsn;

        /* The current apply lag between the slave and the master */
        uint64_t    m_sync_lag;

        /* The number of the false lag */
        uint64_t    m_false_lag;

        /* The rtt of the network */
        uint64_t    m_rtt;

        /* The newest sync timestamp in the master */
        uint64_t    m_master_ts;

        /* The newest sync timestamp in the slave */
        uint64_t    m_slave_ts;

        /* The queue saves every sync information */
        sync_queue_t    sync_queue;
    };
private:
    /* Ring buffer for redo log */
    aligned_pointer<LogRingBuffer> *m_rbuf_obj;

    /* Ring buffer for redo log */
    LogRingBuffer*  m_rbuf;

    /* Lsn members which could be modified frequently,
    because we don't make aligned for the rpl_sys so
    we can only add pad size for each of them to avoid
    false sharing */
    char        pad1[CACHE_LINE_SIZE];
    /* Received log lsn */
    atomic_lsn_t    m_received_lsn;

    char        pad2[CACHE_LINE_SIZE];
    /* Scanned log lsn */
    atomic_lsn_t    m_scanned_lsn;

    char        pad3[CACHE_LINE_SIZE];
    /* Applied log lsn */
    atomic_lsn_t    m_applied_lsn;

    char        pad4[CACHE_LINE_SIZE];
    /* mutex protecting the m_sync_info and parameters
    about master info*/
    ib_mutex_t  m_rpl_mutex;
    char        pad5[CACHE_LINE_SIZE];

    /* The time sync information about replication */
    sync_info   m_sync_info;

    /* Comes from the srv_server_lsn of the master,
    if the recovered lsn is larger than this lsn
    all the mdl locks should be released, corresponding
    to the lsn named srv_server_lsn from the master */
    lsn_t       m_recv_ddl_lsn;

    /* Comes from the srv_start_lsn of the master,
    record the latest restart lsn of the master
    for the slave relogined */
    lsn_t       m_restart_lsn;

    /* Login lsn from master after login */
    lsn_t       m_login_lsn;

public:
    /* mutex protecting the read_lsn_map */
    ib_mutex_t  m_mutex;

    char        pad6[CACHE_LINE_SIZE];
    /* Read lsn for page io */
    atomic_lsn_t    m_read_lsn;
    char        pad7[CACHE_LINE_SIZE];

    bool        m_sp_changed;
    bool        m_acl_changed;

    byte*       m_buf;  /*!< buffer for parsing log records */
    ulint       m_len;  /*!< amount of data in buf */
    ulint       m_recovered_offset;
    lsn_t       m_parse_start_lsn;
                /*!< this is the lsn from which we were able to
                start parsing log records and adding them to
                the hash table; zero if a suitable
                start point not found yet */

    static lsn_t    m_recovered_lsn;

    static bool m_found_corrupt_log;
    bool        m_found_corrupt_fs;

    /* Index of MLOG_INDEX_LOCK_ACQUIRE */
    static dict_index_t*    m_lock_acquire_index;

#ifndef DBUG_OFF
    lsn_t       m_total_undo_len;
    lsn_t       m_total_len;
    lsn_t       m_total_undo_recs;
    lsn_t       m_total_recs;
    lsn_t       m_total_undo_pages;
    lsn_t       m_total_pages;
#endif

    std::atomic<bool>   m_slave_running;

    /* The tidb redo_log_scan thread waits on this event. */
    os_event_t      m_scan_start_event = NULL;
};            
```