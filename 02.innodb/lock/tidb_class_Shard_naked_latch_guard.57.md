#1.Shard_naked_latch_guard

```cpp
/**
A RAII helper which latches the mutex protecting given shard during constructor,
and unlatches it during destruction.
You quite probably don't want to use this class, which only takes a shard's
latch, without acquiring global_latch - which gives no protection from threads
which latch only the global_latch exclusively to prevent any activity.
You should use it in combination with Global_shared_latch_guard, so that you
first obtain an s-latch on the global_latch, or simply use the Shard_latch_guard
class which already combines the two for you.
*/
class Shard_naked_latch_guard : private ut::Non_copyable {
        explicit Shard_naked_latch_guard(Lock_mutex &shard_mutex);

public:
        explicit Shard_naked_latch_guard(const dict_table_t &table);

        explicit Shard_naked_latch_guard(const page_id_t &page_id);

        ~Shard_naked_latch_guard();

private:
        /** The mutex protecting the shard requested in constructor */
        Lock_mutex &m_shard_mutex;
};
```

#2.constructor

```cpp
/* Shard_naked_latch_guard */

Shard_naked_latch_guard::Shard_naked_latch_guard(Lock_mutex &shard_mutex)
    : m_shard_mutex(shard_mutex) {
  ut_ad(owns_shared_global_latch());
  mutex_enter(&m_shard_mutex);
}

Shard_naked_latch_guard::Shard_naked_latch_guard(const dict_table_t &table)
    : Shard_naked_latch_guard{lock_sys->latches.table_shards.get_mutex(table)} {
}

Shard_naked_latch_guard::Shard_naked_latch_guard(const page_id_t &page_id)
    : Shard_naked_latch_guard{
          lock_sys->latches.page_shards.get_mutex(page_id)} {}

Shard_naked_latch_guard::~Shard_naked_latch_guard() {
  mutex_exit(&m_shard_mutex);
}

```