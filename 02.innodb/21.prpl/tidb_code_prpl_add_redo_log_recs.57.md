#1.prpl_add_redo_log_recs

```cpp
prpl_add_redo_log_recs
--if (rpl_addr == NULL)
----heap = mem_heap_create(256);
----rpl_addr = static_cast<rpl_addr_t*>(mem_heap_alloc(heap, sizeof(rpl_addr_t)));
----UT_LIST_INIT(rpl_addr->rec_list, &rpl_rec_t::rec_list);
--for (auto rec = UT_LIST_GET_FIRST(slot->rec_list); rec != NULL;rec = UT_LIST_GET_NEXT(rec_list, rec))
----rpl_rec = static_cast<rpl_rec_t*>(mem_heap_alloc(rpl_addr->heap, sizeof(rpl_rec_t) + rec->len));
----rpl_rec->data = reinterpret_cast<byte*>(rpl_rec) + sizeof(rpl_rec_t);
----memcpy(rpl_rec->data, rec->data, rec->len);
----rpl_rec->len = rec->len;
----UT_LIST_ADD_LAST(rpl_addr->rec_list, rpl_rec);
```