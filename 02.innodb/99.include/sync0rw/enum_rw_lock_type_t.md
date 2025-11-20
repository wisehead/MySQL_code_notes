#1.enum rw_lock_type_t

```cpp
enum rw_lock_type_t {
    RW_S_LATCH = 1,   //共享锁
    RW_X_LATCH = 2,   //排它锁
    RW_SX_LATCH = 4,  //意向排它锁，阻塞写操作，不阻塞读操作
    RW_NO_LATCH = 8   //没有锁
};
```