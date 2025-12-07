#1.Latches::Unique_sharded_rw_lock

```cpp

class Latches {

        /** A helper wrapper around Shared_rw_lock which simplifies:
        - lifecycle by providing constructor and destructor, and
        - s-latching and s-unlatching by keeping track of the shard id used for
                spreading the contention.
        There must be at most one instance of this class (the one in the lock_sys), as
        it uses thread_local-s to remember which shard of sharded rw lock was used by
        this thread to perform s-latching (so, hypothetical other instances would
        share this field, overwriting it and leading to errors). */
        class Unique_sharded_rw_lock {
                /** The actual rw_lock implementation doing the heavy lifting */
                Sharded_rw_lock rw_lock;

                /** The value used for m_shard_id to indicate that current thread did not
                s-latch any of the rw_lock's shards */
                static constexpr size_t NOT_IN_USE = std::numeric_limits<size_t>::max();

                /** The id of the rw_lock's shard which this thread has s-latched, or
                NOT_IN_USE if it has not s-latched any*/
                static thread_local size_t m_shard_id;

        public:
                Unique_sharded_rw_lock();
                ~Unique_sharded_rw_lock();
                bool try_x_lock() { return rw_lock.try_x_lock(); }
                void x_lock() { rw_lock.x_lock(); }
                void x_unlock() { rw_lock.x_unlock(); }
                void s_lock()
                {
                        ut_ad(m_shard_id == NOT_IN_USE);
                        m_shard_id = rw_lock.s_lock();
                }
                void s_unlock() {
                        ut_ad(m_shard_id != NOT_IN_USE);
                        rw_lock.s_unlock(m_shard_id);
                        m_shard_id = NOT_IN_USE;
                }
#ifdef UNIV_DEBUG
                bool x_own() const { return rw_lock.x_own(); }
                bool s_own() const {
                        return m_shard_id != NOT_IN_USE && rw_lock.s_own(m_shard_id);
                }
#endif
        };
```