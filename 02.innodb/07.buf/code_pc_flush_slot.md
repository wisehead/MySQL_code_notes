#1. pc_flush_slot

```cpp
/**
Do flush for one slot.
@return the number of the slots which has not been treated yet. */

pc_flush_slot
--for (i = 0; i < page_cleaner->n_slots; i++)
--if (slot->state == PAGE_CLEANER_STATE_REQUESTED) break;
--//end for
--page_cleaner->n_slots_requested--;
--page_cleaner->n_slots_flushing++;
--slot->state = PAGE_CLEANER_STATE_FLUSHING;
--buf_flush_LRU_list
--buf_flush_do_batch(buf_pool, BUF_FLUSH_LIST, slot->n_pages_requested,page_cleaner->lsn_limit, &slot->n_flushed_list);
--page_cleaner->n_slots_flushing--;
--page_cleaner->n_slots_finished++;
--slot->state = PAGE_CLEANER_STATE_FINISHED;
--if (page_cleaner->n_slots_requested == 0 && page_cleaner->n_slots_flushing == 0) {os_event_set(page_cleaner->is_finished);}

```

#2.caller

##2.1 buf_flush_page_cleaner_thread
```cpp
buf_flush_page_cleaner_thread
--pc_flush_slot
```

##2.2 buf_flush_page_coordinator_thread
