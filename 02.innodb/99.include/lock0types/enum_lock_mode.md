#1.enum lock_mode


```cpp
enum lock_mode {
    LOCK_IS = 0,   /* intention shared */     //意向共享锁
    LOCK_IX,       /* intention exclusive */  //意向排它锁
    LOCK_S,        /* shared */               //共享锁
    LOCK_X,        /* exclusive */            //排它锁
    LOCK_AUTO_INC,    /* locks the auto-inc counter of a tablein an exclusive mode */
                                                 //自增锁。简称AI
    LOCK_NONE,    /* this is used elsewhere to note consistent read */
    LOCK_NUM = LOCK_NONE, /* number of lock modes */
    LOCK_NONE_UNSET = 255
};
```