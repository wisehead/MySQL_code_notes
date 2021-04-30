#1.struct lock_sys_t

```cpp
/** The lock system struct */
struct lock_sys_t{
        locksys::Latches latches;               /** The latches protecting queues of
                                                record and table locks */
        hash_table_t*   rec_hash;               /*!< hash table of the record
                                                locks */
        hash_table_t*   prdt_hash;              /*!< hash table of the predicate
                                                lock */
        hash_table_t*   prdt_page_hash;         /*!< hash table of the page
                                                lock */

        char            pad2[CACHE_LINE_SIZE];  /*!< Padding */
        Lock_mutex      wait_mutex;             /*!< Mutex protecting the
                                                next two fields */
        srv_slot_t*     waiting_threads;        /*!< Array  of user threads
                                                suspended while waiting for
                                                locks within InnoDB, protected
                                                by the lock_sys->wait_mutex */
        srv_slot_t*     last_slot;              /*!< highest slot ever used
                                                in the waiting_threads array,
                                                protected by
                                                lock_sys->wait_mutex */
        bool            rollback_complete;
                                                /*!< TRUE if rollback of all
                                                recovered transactions is
                                                complete. Protected by
                                                lock_sys->mutex */

        ulint           n_lock_max_wait_time;   /*!< Max wait time */

        os_event_t      timeout_event;          /*!< Set to the event that is
                                                created in the lock wait monitor
                                                thread. A value of 0 means the
                                                thread is not active */

        bool            timeout_thread_active;  /*!< True if the timeout thread
                                                is running */

#ifdef UNIV_DEBUG
        /** Lock timestamp counter, used to assign lock->m_seq on creation. */
        std::atomic<uint64_t> m_seq;
#endif /* UNIV_DEBUG */
};
```