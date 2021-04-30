#1.Shard_latch_guard

```cpp
/**
A RAII wrapper class which combines Global_shared_latch_guard and
Shard_naked_latch_guard to s-latch the global lock_sys latch and latch the mutex
protecting the specified shard for the duration of its scope.
The order of initialization is important: we have to take shared global latch
BEFORE we attempt to use hash function to compute correct shard and latch it. */
class Shard_latch_guard {
        Global_shared_latch_guard m_global_shared_latch_guard;
        Shard_naked_latch_guard m_shard_naked_latch_guard;

public:
        explicit Shard_latch_guard(const dict_table_t &table)
                : m_global_shared_latch_guard{}, m_shard_naked_latch_guard{table} {}

        explicit Shard_latch_guard(const page_id_t &page_id)
                : m_global_shared_latch_guard{}, m_shard_naked_latch_guard{page_id} {}
};
```

#2.

```cpp

```