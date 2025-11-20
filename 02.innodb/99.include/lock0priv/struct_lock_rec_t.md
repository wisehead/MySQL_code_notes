#1.struct lock_rec_t

```cpp
/** Record lock for a page */
struct lock_rec_t {  记录锁
    ib_uint32_t    space;   /*!< space id */       //记录在哪个表空间中
    ib_uint32_t    page_no; /*!< page number */    //记录在哪个页面中
    ib_uint32_t    n_bits;  /*!< number of bits in the lockbitmap; NOTE: the lock
    bitmap isplaced immediately after the lock struct */
};  //本结构体之后紧跟着一个位图，标记了一个页面中有哪些记录被加锁。这说明记录锁不是施加在记录
上的，而是施加在页面上的，但不是页锁
```