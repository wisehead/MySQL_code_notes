#1.os_atomic_decrement_lint

```cpp
//storage/innobase/include/os0atomic.h


/* Returns the resulting value, ptr is pointer to target, amount is the
amount to decrement. */

#if defined(HAVE_GCC_SYNC_BUILTINS)
# define os_atomic_decrement(ptr, amount) \
        __sync_sub_and_fetch(ptr, amount)
#else
# define os_atomic_decrement(ptr, amount) \
        __atomic_sub_fetch(ptr, amount, __ATOMIC_SEQ_CST)
#endif /* HAVE_GCC_SYNC_BUILTINS */

# define os_atomic_decrement_lint(ptr, amount) \
        os_atomic_decrement(ptr, amount)
```