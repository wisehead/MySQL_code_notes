#1.Global_exclusive_try_latch

```cpp
/**
A RAII helper which tries to exclusively latch the global_lach in constructor
and unlatches it, if needed, during destruction, preventing any other threads
from activity within lock_sys for it's entire scope, if owns_lock().
*/
class Global_exclusive_try_latch : private ut::Non_copyable {
public:
        Global_exclusive_try_latch();
        ~Global_exclusive_try_latch();
        /** Checks if succeeded to latch the global_latch during construction.
        @return true iff the current thread owns (through this instance) the exclusive
        global lock_sys latch */
        bool owns_lock() const noexcept { return m_owns_exclusive_global_latch; }

private:
        /** Did the constructor succeed to acquire exclusive global lock_sys latch? */
        bool m_owns_exclusive_global_latch;
};
```

#2.constructor

```cpp
/* Global_exclusive_try_latch */

Global_exclusive_try_latch::Global_exclusive_try_latch() {
  m_owns_exclusive_global_latch = lock_sys->latches.global_latch.try_x_lock();
}

Global_exclusive_try_latch::~Global_exclusive_try_latch() {
  if (m_owns_exclusive_global_latch) {
    lock_sys->latches.global_latch.x_unlock();
    m_owns_exclusive_global_latch = false;
  }
}
```