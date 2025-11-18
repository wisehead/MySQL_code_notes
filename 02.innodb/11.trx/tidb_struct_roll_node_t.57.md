#1.roll_node_t

```cpp
/** Rollback command node in a query graph */
struct roll_node_t{
    que_common_t        common; /*!< node type: QUE_NODE_ROLLBACK */
    enum roll_node_state    state;  /*!< node execution state */
    bool            partial;/*!< TRUE if we want a partial
                    rollback */
    trx_savept_t        savept; /*!< savepoint to which to
                    roll back, in the case of a
                    partial rollback */
    que_thr_t*      undo_thr;/*!< undo query graph */
};

```