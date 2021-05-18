#1.class tidb_node

```cpp
class tidb_node
{
public:
private:
    /* Role of node */
    tidb_NODE_ROLE  m_role;

    /* Instance id, same in both master and slave */
    uint128_t   m_inst_id;

    /* Node id configured by OSS */
    ulint       m_node_id;

    /*
    Master:
      NODE_MASTER   IP address itself
      NODE_SLAVE    Slave's ip address
    Slave:
      NODE_SLAVE    Master's ip address
    */
    char        m_peer_addr[64];

    /*
    Master:
      NODE_MASTER   Serving port itself
      NODE_SLAVE    Serving port in slave
    Slave:
      NODE_SLAVE    Serving port in master
    */
    int     m_peer_port;

    /* Node information string for print log */
    char        m_node_str[128];

    /*
    Slave:
      Node tidb log buffer size
    */
    uint64_t        m_log_buffer_size;

    /*
    Master:
      NODE_MASTER   NODE_STATE_ONLINE
      NODE_SLAVE    Current state
    Slave:
      NODE_SLAVE    Current state
    */
    tidb_NODE_STATE m_state;
    /*
    Master:
      NODE_MASTER   log lsn has been sent up to dbclient
      NODE_SLAVE    log lsn han been sent up to slave
    Slave:
      NODE_SLAVE    log lsn han been received up to in slave(same as m_receive_lsn)
    */
    lsn_t       m_trans_lsn;

    /*
    Master:
      NODE_MASTER   Current VDL in master
      NODE_SLAVE    VDL latest send to slave
    Slave:
      NODE_SLAVE    VDL latest received in slave
    */
    lsn_t       m_trans_vdl;

    /*
    Master:
      NODE_MASTER   Current lsn in master
      NODE_SLAVE    Received lsn comes from slave
    Slave:
      NODE_SLAVE    Received lsn in slave
    */
    lsn_t       m_receive_lsn;

    /*
    Master:
      NODE_MASTER   Current applied lsn in master
      NODE_SLAVE    Applied lsn comes from slave
    Slave:
      NODE_SLAVE    Applied lsn in slave
    */
    lsn_t       m_current_lsn;

    /*
    Master:
      NODE_MASTER   Oldest trx no from readview in master
      NODE_SLAVE    Oldest trx no comes from slave
    Slave:
      NODE_SLAVE    Oldest trx no in slave
    */
    uint64_t    m_low_no;

    /*
    Master:
      NODE_MASTER   0
      NODE_SLAVE    the log lag between the master and the slave
    Slave:
      NODE_SLAVE    the log lag between the master and the slave
    */
    uint64_t    m_lag;

    /*
    Master:
      NODE_MASTER   0
      NODE_SLAVE    the number of the false lag of the slave
    Slave:
      NODE_SLAVE    the number of the false lag of the slave
    */
    uint64_t    m_false_lag;
    /*
    Master:
      NODE_MASTER   Current recycle lsn in master
      NODE_SLAVE    Recycle lsn comes from slave
    Slave:
      NODE_SLAVE    Recycle lsn in slave from ongoing page IO
    */
    lsn_t       m_recycle_lsn;

    /*
    Master:
      NODE_MASTER   Send position in log ring buffer for dbclient
      NODE_SLAVE    Rpl send position in log ring buffer for this slave node
    Slave:
      NODE_SLAVE    rpl_bound in rpl_sys's ring buffer
    */
    uint64_t    m_rpl_pos;

    /* Timestamp when node set to delete */
    uint64_t    m_del_ts;

    /* The latest lsn which sync the time */
    lsn_t       m_sync_lsn;

    /* Temporary space allocated size in the node */
    uint64_t    m_space_alloc;

    /* Temporary space used size in the node */
    uint64_t    m_space_used;

    /*
    Master:
      NODE_MASTER   socket for master's server loop
      NODE_SLAVE    socket for communicating with slave
            same as the socket in tidb_conn
    Slave:
      NODE_SLAVE    INVALID_SOCKET, use m_conn instead
    */
    int     m_sock;

    /* Connection port between master and slave */
    int     m_port;

    /* Signal event */
    os_event_t  m_event;

    /* Connection between master and slave just
    for node in slave */
    tidb_conn*  m_conn;

    /* Extra node for the clock synchronization */
    tidb_node*  m_extra_node;

    /* Main node for the extra node */
    tidb_node*  m_node;

    /* Node manager */
    node_manager*   m_nmgr;

    /* False if connection is not available,
    protected by mutex in node manager */
    std::atomic<bool>   m_active;

    /* True if node has completed login,
    protected by mutex in node manager */
    bool        m_login;

    /* True if node is the main node */
    bool        m_main;

    /* True if node worker thread is alive,
    protected by mutex in node manager.
    For master node worker thread is master_server
    thread, and slave_send thread for slave node */
    std::atomic<bool>   m_worker_thd_alive;

    /* True if the node holds the rpl pos */
    bool        m_lock_rpl;

    /* True if the node holds the low no in trx_sys */
    bool        m_lock_trx_no;

    /* True if the node is a extra node for clock sync */
    bool        m_extra;

    /* True if node worker thread is working */
    bool        m_working;
};            
```