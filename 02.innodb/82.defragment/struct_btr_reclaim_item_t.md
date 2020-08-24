#1.btr_reclaim_item_t

```cpp
/** Item in the work queue for btr_reclaim_thread. */
struct btr_reclaim_item_t
{
    char        table[FN_REFLEN]; /* Table name */
    btr_index_map index_map;
    // dict_index_t *index;
    // btr_pcur_t *pcur;       /* persistent cursor where
    //                 btr_reclaim_n_pages should start */
    bool        removed;    /* Mark an item as removed */
    ulonglong   create_time;    /* item create time */
    ulonglong   last_processed; /* timestamp of last time this index
                    is processed by defragment thread */
    ulint page_no;/* Move record from this page_no */
    ulint space;

    btr_reclaim_item_t(dict_index_t* index);

    ~btr_reclaim_item_t();
};

```