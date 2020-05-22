#1.que_thr_t

```cpp
/* Query graph query thread node: the fields are protected by the
trx_t::mutex with the exceptions named below */

struct que_thr_t{
    que_common_t    common;     /*!< type: QUE_NODE_THR */
    ulint       magic_n;    /*!< magic number to catch memory
                    corruption */
    que_node_t* child;      /*!< graph child node */
    que_t*      graph;      /*!< graph where this node belongs */
    ulint       state;      /*!< state of the query thread */
    ibool       is_active;  /*!< TRUE if the thread has been set
                    to the run state in
                    que_thr_move_to_run_state, but not
                    deactivated in
                    que_thr_dec_reference_count */
    /*------------------------------*/
    /* The following fields are private to the OS thread executing the
    query thread, and are not protected by any mutex: */

    que_node_t* run_node;   /*!< pointer to the node where the
                    subgraph down from this node is
                    currently executed */
    que_node_t* prev_node;  /*!< pointer to the node from which
                    the control came */
    ulint       resource;   /*!< resource usage of the query thread
                    thus far */
    ulint       lock_state; /*!< lock state of thread (table or
                    row) */
    struct srv_slot_t*
            slot;       /* The thread slot in the wait
                    array in srv_sys_t */
    /*------------------------------*/
    /* The following fields are links for the various lists that
    this type can be on. */
    UT_LIST_NODE_T(que_thr_t)
            thrs;       /*!< list of thread nodes of the fork
                    node */
    UT_LIST_NODE_T(que_thr_t)
            trx_thrs;   /*!< lists of threads in wait list of
                    the trx */
    UT_LIST_NODE_T(que_thr_t)
            queue;      /*!< list of runnable thread nodes in
                    the server task queue */
    ulint       fk_cascade_depth; /*!< maximum cascading call depth
                    supported for foreign key constraint
                    related delete/updates */
};

```