#1.Shard_naked_latches_guard

```cpp
/**
A RAII helper which latches the mutexes protecting specified shards for the
duration of its scope.
It makes sure to take the latches in correct order and handles the case where
both pages are in the same shard correctly.
You quite probably don't want to use this class, which only takes a shard's
latch, without acquiring global_latch - which gives no protection from threads
which latch only the global_latch exclusively to prevent any activity.
You should use it in combination with Global_shared_latch_guard, so that you
first obtain an s-latch on the global_latch, or simply use the
Shard_latches_guard class which already combines the two for you.
*/
class Shard_naked_latches_guard {
        explicit Shard_naked_latches_guard(Lock_mutex &shard_mutex_a,
                                     Lock_mutex &shard_mutex_b);

public:
        explicit Shard_naked_latches_guard(const buf_block_t &block_a,
                                     const buf_block_t &block_b);

        ~Shard_naked_latches_guard();

private:
        /** The "smallest" of the two shards' mutexes in the latching order */
        Lock_mutex &m_shard_mutex_1;
        /** The "largest" of the two shards' mutexes in the latching order */
        Lock_mutex &m_shard_mutex_2;
        /** The ordering on shard mutexes used to avoid deadlocks */
        static constexpr std::less<Lock_mutex *> MUTEX_ORDER{};
};
```

#2.constructor


```cpp
/* Shard_naked_latches_guard */

Shard_naked_latches_guard::Shard_naked_latches_guard(Lock_mutex &shard_mutex_a,
                                                     Lock_mutex &shard_mutex_b)
    : m_shard_mutex_1(*std::min(&shard_mutex_a, &shard_mutex_b, MUTEX_ORDER)),
      m_shard_mutex_2(*std::max(&shard_mutex_a, &shard_mutex_b, MUTEX_ORDER)) {
  ut_ad(owns_shared_global_latch());
  if (&m_shard_mutex_1 != &m_shard_mutex_2) {
    mutex_enter(&m_shard_mutex_1);
  }
  mutex_enter(&m_shard_mutex_2);
}

Shard_naked_latches_guard::Shard_naked_latches_guard(const buf_block_t &block_a,
                                                     const buf_block_t &block_b)
    : Shard_naked_latches_guard{
          lock_sys->latches.page_shards.get_mutex(block_a.get_page_id()),
          lock_sys->latches.page_shards.get_mutex(block_b.get_page_id())} {}

Shard_naked_latches_guard::~Shard_naked_latches_guard() {
  mutex_exit(&m_shard_mutex_2);
  if (&m_shard_mutex_1 != &m_shard_mutex_2) {
    mutex_exit(&m_shard_mutex_1);
  }
}
```