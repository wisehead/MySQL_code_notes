#1.struct lock_rec_t

```cpp
/** Record lock for a page */
struct lock_rec_t {
    ulint   space;          /*!< space id */
    ulint   page_no;        /*!< page number */
    ulint   n_bits;         /*!< number of bits in the lock
                    bitmap; NOTE: the lock bitmap is
                    placed immediately after the
                    lock struct */
};

```