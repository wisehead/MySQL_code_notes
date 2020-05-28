#1.struct __toku_indexer_internal

```cpp
struct __toku_indexer_internal {
    DB_ENV *env;
    DB_TXN *txn;
    toku_mutex_t indexer_lock;
    toku_mutex_t indexer_estimate_lock;
    DBT position_estimate;
    DB *src_db;
    int N;
    DB **dest_dbs; /* [N] */
    uint32_t indexer_flags;
    void (*error_callback)(DB *db, int i, int err, DBT *key, DBT *val, void *error_extra);
    void *error_extra;
    int  (*poll_func)(void *poll_extra, float progress);
    void *poll_extra;
    uint64_t estimated_rows; // current estimate of table size
    uint64_t loop_mod;       // how often to call poll_func
    LE_CURSOR lec;
    FILENUM  *fnums; /* [N] */
    FILENUMS filenums;

    // undo state
    struct indexer_commit_keys commit_keys; // set of keys to commit
    DBT_ARRAY *hot_keys;
    DBT_ARRAY *hot_vals;

    // test functions
    int (*undo_do)(DB_INDEXER *indexer, DB *hotdb, DBT* key, ULEHANDLE ule);
    TOKUTXN_STATE (*test_xid_state)(DB_INDEXER *indexer, TXNID xid);
    void (*test_lock_key)(DB_INDEXER *indexer, TXNID xid, DB *hotdb, DBT *key);
    int (*test_delete_provisional)(DB_INDEXER *indexer, DB *hotdb, DBT *hotkey, XIDS xids);
    int (*test_delete_committed)(DB_INDEXER *indexer, DB *hotdb, DBT *hotkey, XIDS xids);
    int (*test_insert_provisional)(DB_INDEXER *indexer, DB *hotdb, DBT *hotkey, DBT *hotval, XIDS xids);
    int (*test_insert_committed)(DB_INDEXER *indexer, DB *hotdb, DBT *hotkey, DBT *hotval, XIDS xids);
    int (*test_commit_any)(DB_INDEXER *indexer, DB *db, DBT *key, XIDS xids);

    // test flags
    int test_only_flags;
};
```