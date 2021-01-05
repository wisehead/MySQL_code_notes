#1.class ReadView
```cpp
/** Read view lists the trx ids of those transactions for which a consistent
read should not see the modifications to the database. */

class ReadView {
    /** This is similar to a std::vector but it is not a drop
    in replacement. It is specific to ReadView. */
    class ids_t {
        typedef trx_ids_t::value_type value_type;
    private:
        /** Memory for the array */
        value_type* m_ptr;

        /** Number of active elements in the array */
        ulint       m_size;

        /** Size of m_ptr in elements */
        ulint       m_reserved;

        friend class ReadView;
    };
private:
    /** The read should not see any transaction with trx id >= this
    value. In other words, this is the "high water mark". */
    trx_id_t    m_low_limit_id;

    /** The read should see all trx ids which are strictly
    smaller (<) than this value.  In other words, this is the
    low water mark". */
    trx_id_t    m_up_limit_id;

    /** trx id of creating transaction, set to TRX_ID_MAX for free
    views. */
    trx_id_t    m_creator_trx_id;

    /** Set of RW transactions that was active when this snapshot
    was taken */
    ids_t       m_ids;

    /** The view does not need to see the undo logs for transactions
    whose transaction number is strictly smaller (<) than this value:
    they can be removed in purge if not needed by other views */
    trx_id_t    m_low_limit_no;

    /** AC-NL-RO transaction view that has been "closed". */
    bool        m_closed;

    typedef UT_LIST_NODE_T(ReadView) node_t;

    /** List of read views in trx_sys */
    byte        pad1[64 - sizeof(node_t)];
    node_t      m_view_list;

        std::atomic<uint64> ref_count;
};


        
```