#1.struct lock_prdt

```cpp

typedef struct lock_prdt {
    void*        data;  /* Predicate data */
    uint16       op;    /* Predicate operator */
} lock_prdt_t;
```