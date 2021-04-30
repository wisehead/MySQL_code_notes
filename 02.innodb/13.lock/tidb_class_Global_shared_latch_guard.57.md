#1.Global_shared_latch_guard

```cpp
/**
A RAII helper which latches global_latch in shared mode during constructor,
and unlatches it during destruction, preventing any other thread from acquiring
exclusive latch. This should be used in combination Shard_naked_latch_guard,
preferably by simply using Shard_latch_guard which combines the two for you.
*/
class Global_shared_latch_guard : private ut::Non_copyable {
public:
        Global_shared_latch_guard();
        ~Global_shared_latch_guard();
};
```

#2.constructor

```cpp
/* Global_shared_latch_guard */

Global_shared_latch_guard::Global_shared_latch_guard() {
  lock_sys->latches.global_latch.s_lock();
}

Global_shared_latch_guard::~Global_shared_latch_guard() {
  lock_sys->latches.global_latch.s_unlock();
}
```