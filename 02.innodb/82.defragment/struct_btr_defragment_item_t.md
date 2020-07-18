#1.struct btr_defragment_item_t

```cpp
/** Item in the work queue for btr_degrament_thread. */
struct btr_defragment_item_t
{
    btr_pcur_t* pcur;       /* persistent cursor where
                    btr_defragment_n_pages should start */
    os_event_t  event;      /* if not null, signal after work
                    is done */
    bool        removed;    /* Mark an item as removed */
    ulonglong   last_processed; /* timestamp of last time this index
                    is processed by defragment thread */
    bool        reclaimed;  /* Continue reclaim after defragmention*/
    dict_index_t *index;
    ulint       space;      /* Space id of table that index belongs to */

    btr_defragment_item_t(btr_pcur_t* pcur, os_event_t event,
            dict_index_t* index, ulint space);
    ~btr_defragment_item_t();
1. };
```