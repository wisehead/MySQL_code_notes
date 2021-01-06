#1.struct mtr_t

```cpp
/** Mini-transaction handle and buffer */
struct mtr_t {

    /** State variables of the mtr */
    struct Impl {

        /** memo stack for locks etc. */
        mtr_buf_t   m_memo;

        /** mini-transaction log */
        mtr_page_buf_t  m_log;

        /** mini-transaction log head */
        mtr_page_buf_t* m_log_head;

        /* pointer to mtr_page_buf's write_header */
        bool*       m_write_header;

        /** true if mtr has made at least one buffer pool page dirty */
        bool        m_made_dirty;

        /** true if inside ibuf changes */
        bool        m_inside_ibuf;

        /** true if the mini-transaction modified buffer pool pages */
        bool        m_modifications;

        /** Count of how many page initial log records have been
        written to the mtr log */
        ib_uint32_t m_n_log_recs;

        /** specifies which operations should be logged; default
        value MTR_LOG_ALL */
        mtr_log_t   m_log_mode;


#ifdef UNIV_DEBUG
        /** Persistent user tablespace associated with the
        mini-transaction, or 0 (TRX_SYS_SPACE) if none yet */
        ulint       m_user_space_id;
#endif /* UNIV_DEBUG */
        /** User tablespace that is being modified by the
        mini-transaction */
        fil_space_t*    m_user_space;
        /** Undo tablespace that is being modified by the
        mini-transaction */
        fil_space_t*    m_undo_space;
        /** System tablespace if it is being modified by the
        mini-transaction */
        fil_space_t*    m_sys_space;

        /** State of the transaction */
        mtr_state_t m_state;

        /** Flush Observer */
        FlushObserver*  m_flush_observer;

        /** ture if bulk load */
        bool        m_bulk_load;

        /** ture if an MLOG_INDEX_LOCK_ACQUIRE record has been
        written by the mini-transaction */
        bool        m_index_lock_acquire;

#ifdef UNIV_DEBUG
        /** For checking corruption. */
        ulint       m_magic_n;
#endif /* UNIV_DEBUG */

        /** Owning mini-transaction */
        mtr_t*      m_mtr;

#if !defined(NCDB_DB_UTEST)
        /** Really modified page set */
        std::set<page_id_t> m_modified_page_set;
#endif /* !NCDB_DB_UTEST */

        /** mtr needs to record checksum */
        bool        m_rec_checksum;

        /** The length for the fast buffer */
        ulint       m_fast_len;

        /** The buffer for the fast mtr */
        byte        m_fast_buf[MTR_FAST_BUF_LENGTH];
    };

private:
    Impl            m_impl;

    /** LSN at commit time */
    volatile lsn_t      m_commit_lsn;

    /** true if it is synchronous mini-transaction */
    bool            m_sync;

    /** true if it is a fast mtr */
    bool            m_fast;

    /* space_id of page what the mtr will immediately write log about */
    uint32_t        m_space_id;

    /* page_no of page what the mtr will immediately write log about */
    uint32_t        m_page_no;

    /* page_lsn of page what the mtr will immediately write log about */
    lsn_t           m_page_lsn;

    /* current in use for attached page */
    mtr_buf_t*      m_current_buf;
};            
```