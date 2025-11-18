#1.trx_purge_graph_build

```cpp
trx_purge_graph_build
--que_fork_create
--for (i = 0; i < n_purge_threads; ++i)
----que_thr_create
----row_purge_node_create
--//end for
```