#1.que_thr_create

```cpp
que_thr_create
--mem_heap_zalloc(heap, sizeof(*thr))
--thr->graph = parent->graph
--thr->common.parent = parent
--thr->common.type = QUE_NODE_THR;
--thr->state = QUE_THR_COMMAND_WAIT
--UT_LIST_ADD_LAST(parent->thrs, thr);
```