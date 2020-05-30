#1.rw_lock_t

```cpp
/** The structure used in the spin lock implementation of a read-write
lock. Several threads may have a shared lock simultaneously in this
lock, but only one writer may have an exclusive lock, in which case no
shared locks are allowed. To prevent starving of a writer blocked by
readers, a writer may queue for x-lock by decrementing lock_word: no
new readers will be let in while the thread waits for readers to
exit. */
struct rw_lock_t {
    volatile lint   lock_word;
                /*!< Holds the state of the lock. */
    volatile ulint  waiters;/*!< 1: there are waiters */
    volatile ibool  recursive;/*!< Default value FALSE which means the lock
                is non-recursive. The value is typically set
                to TRUE making normal rw_locks recursive. In
                case of asynchronous IO, when a non-zero
                value of 'pass' is passed then we keep the
                lock non-recursive.
                This flag also tells us about the state of
                writer_thread field. If this flag is set
                then writer_thread MUST contain the thread
                id of the current x-holder or wait-x thread.
                This flag must be reset in x_unlock
                functions before incrementing the lock_word */
    volatile ulint  sx_recursive;/*!< number of granted SX locks. */
    volatile os_thread_id_t writer_thread;
                /*!< Thread id of writer thread. Is only
                guaranteed to have sane and non-stale
                value iff recursive flag is set. */
    os_event_t  event;  /*!< Used by sync0arr.cc for thread queueing */
    os_event_t  wait_ex_event;
                /*!< Event for next-writer to wait on. A thread
                must decrement lock_word before waiting. */
#ifndef INNODB_RW_LOCKS_USE_ATOMICS
    ib_mutex_t  mutex;      /*!< The mutex protecting rw_lock_t */
#endif /* INNODB_RW_LOCKS_USE_ATOMICS */

    UT_LIST_NODE_T(rw_lock_t) list;
                /*!< All allocated rw locks are put into a
                list */
#ifdef UNIV_SYNC_DEBUG
    UT_LIST_BASE_NODE_T(rw_lock_debug_t) debug_list;
                /*!< In the debug version: pointer to the debug
                info list of the lock */
    ulint   level;      /*!< Level in the global latching order. */
#endif /* UNIV_SYNC_DEBUG */
#ifdef UNIV_PFS_RWLOCK
    struct PSI_rwlock *pfs_psi;/*!< The instrumentation hook */
#endif
    ulint count_os_wait;    /*!< Count of os_waits. May not be accurate */
    const char* cfile_name;/*!< File name where lock created */
        /* last s-lock file/line is not guaranteed to be correct */
    const char* last_s_file_name;/*!< File name where last s-locked */
    const char* last_x_file_name;/*!< File name where last x-locked */
    ibool       writer_is_wait_ex;
                /*!< This is TRUE if the writer field is
                RW_LOCK_WAIT_EX; this field is located far
                from the memory update hotspot fields which
                are at the start of this struct, thus we can
                peek this field without causing much memory
                bus traffic */
    unsigned    cline:14;   /*!< Line where created */
    unsigned    last_s_line:14; /*!< Line number where last time s-locked */
    unsigned    last_x_line:14; /*!< Line number where last time x-locked */
#ifdef UNIV_DEBUG
    ulint   magic_n;    /*!< RW_LOCK_MAGIC_N */
/** Value of rw_lock_t::magic_n */
#define RW_LOCK_MAGIC_N 22643
#endif /* UNIV_DEBUG */
};

#ifdef UNIV_SYNC_DEBUG
/** The structure for storing debug info of an rw-lock.  All access to this
structure must be protected by rw_lock_debug_mutex_enter(). */
struct  rw_lock_debug_t {

    os_thread_id_t thread_id;  /*!< The thread id of the thread which
                locked the rw-lock */
    ulint   pass;       /*!< Pass value given in the lock operation */
    ulint   lock_type;  /*!< Type of the lock: RW_LOCK_EX,
                RW_LOCK_SHARED, RW_LOCK_WAIT_EX */
    const char* file_name;/*!< File name where the lock was obtained */
    ulint   line;       /*!< Line where the rw-lock was locked */
    UT_LIST_NODE_T(rw_lock_debug_t) list;
                /*!< Debug structs are linked in a two-way
                list */
};    
```