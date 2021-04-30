#1.class Global_exclusive_latch_guard

```cpp
/**
A RAII helper which latches global_latch in exclusive mode during constructor,
and unlatches it during destruction, preventing any other threads from activity
within lock_sys for it's entire scope.
*/
class Global_exclusive_latch_guard : private ut::Non_copyable {
public:
        Global_exclusive_latch_guard();
        ~Global_exclusive_latch_guard();
};
```


#2.constructor

```cpp
Global_exclusive_latch_guard::Global_exclusive_latch_guard() {
  lock_sys->latches.global_latch.x_lock();
}
```