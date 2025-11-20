#1.struct lock_t

```cpp
/** Lock struct; protected by lock_sys->mutex */
struct lock_t {
    trx_t*  trx;        /*!< transaction owning thelock */  //哪个事务用于此锁
    UT_LIST_NODE_T(lock_t) trx_locks;    /*!< list of the locks of thetransaction */
    //事务已经申请到的事务的锁的双向列表
    dict_index_t*    index;  /*!< index for a record lock */
    lock_t*          hash;   /*!<hash chain node for a recordlock. The link node
 in a singly linkedlist, used during hashing. */
    union {
        lock_table_t    tab_lock;/*!< table lock */      //表锁
        lock_rec_t      rec_lock;/*!< record lock */     //记录锁
    } un_member;        /*!< lock details */ //union表明一个锁不能同时是表锁和记录锁，
    只能是其一
    ib_uint32_t    type_mode;    /*!< lock type, mode, LOCK_GAP or
    //锁的种类，如上节的说明
                    LOCK_REC_NOT_GAP,
                    LOCK_INSERT_INTENTION,
                    wait flag, ORed */
};
```