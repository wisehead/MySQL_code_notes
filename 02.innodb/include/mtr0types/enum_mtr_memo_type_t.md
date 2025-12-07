#1.enum mtr_memo_type_t

```cpp

/** Types for the mlock objects to store in the mtr memo; NOTE that the first 3
values must be RW_S_LATCH, RW_X_LATCH, RW_NO_LATCH */
enum mtr_memo_type_t {      //各个粒度的锁可以顾名思义，所以不再多述
#ifndef UNIV_INNOCHECKSUM
    MTR_MEMO_PAGE_S_FIX = RW_S_LATCH,
    MTR_MEMO_PAGE_X_FIX = RW_X_LATCH,
    MTR_MEMO_PAGE_SX_FIX = RW_SX_LATCH,
    MTR_MEMO_BUF_FIX = RW_NO_LATCH,
#endif /* !UNIV_CHECKSUM */
#ifdef UNIV_DEBUG
    MTR_MEMO_MODIFY = 32,
#endif /* UNIV_DEBUG */
    MTR_MEMO_S_LOCK = 64,
    MTR_MEMO_X_LOCK = 128,
    MTR_MEMO_SX_LOCK = 256
};
```