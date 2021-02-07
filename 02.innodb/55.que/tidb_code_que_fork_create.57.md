#1.que_fork_create


```cpp
que_fork_create
--fork = static_cast<que_fork_t*>(mem_heap_zalloc(heap, sizeof(*fork)));
--fork->fork_type = fork_type;
--fork->common.parent = parent
--fork->common.type = QUE_NODE_FORK;
--fork->state = QUE_FORK_COMMAND_WAIT;
--fork->graph = (graph != NULL) ? graph : fork;
--UT_LIST_INIT(fork->thrs, &que_thr_t::thrs);
```


#2.fork type

```cpp
/* Query fork (or graph) types */
#define QUE_FORK_SELECT_NON_SCROLL  1   /* forward-only cursor */
#define QUE_FORK_SELECT_SCROLL      2   /* scrollable cursor */
#define QUE_FORK_INSERT         3
#define QUE_FORK_UPDATE         4
#define QUE_FORK_ROLLBACK       5
            /* This is really the undo graph used in rollback,
            no signal-sending roll_node in this graph */
#define QUE_FORK_PURGE          6
#define QUE_FORK_EXECUTE        7
#define QUE_FORK_PROCEDURE      8
#define QUE_FORK_PROCEDURE_CALL     9
#define QUE_FORK_MYSQL_INTERFACE    10
#define QUE_FORK_RECOVERY       11
```