#1.enum lock_mode

```cpp
/* Basic lock modes */
enum lock_mode {
    LOCK_IS = 0,    /* intention shared */
    LOCK_IX,    /* intention exclusive */
    LOCK_S,     /* shared */
    LOCK_X,     /* exclusive */
    LOCK_AUTO_INC,  /* locks the auto-inc counter of a table
            in an exclusive mode */
    LOCK_NONE,  /* this is used elsewhere to note consistent read */
    LOCK_NUM = LOCK_NONE, /* number of lock modes */
    LOCK_NONE_UNSET = 255
};
```

#2.