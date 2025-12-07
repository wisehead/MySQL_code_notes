#1.Shard_latches_guard

```cpp
/**
A RAII wrapper class which s-latches the global lock_sys shard, and mutexes
protecting specified shards for the duration of its scope.
It makes sure to take the latches in correct order and handles the case where
both pages are in the same shard correctly.
The order of initialization is important: we have to take shared global latch
BEFORE we attempt to use hash function to compute correct shard and latch it.
*/
class Shard_latches_guard {
public:
        explicit Shard_latches_guard(const buf_block_t &block_a,
                               const buf_block_t &block_b)
                : m_global_shared_latch_guard{},
                m_shard_naked_latches_guard{block_a, block_b} {}

private:
        Global_shared_latch_guard m_global_shared_latch_guard;
        Shard_naked_latches_guard m_shard_naked_latches_guard;
};
```