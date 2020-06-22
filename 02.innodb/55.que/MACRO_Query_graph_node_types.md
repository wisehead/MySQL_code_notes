#1.MACRO Query graph node types

```cpp
/* Flag which is ORed to control structure statement node types */
#define QUE_NODE_CONTROL_STAT   1024

/* Query graph node types */
#define QUE_NODE_LOCK       1
#define QUE_NODE_INSERT     2
#define QUE_NODE_UPDATE     4
#define QUE_NODE_CURSOR     5
#define QUE_NODE_SELECT     6
#define QUE_NODE_AGGREGATE  7
#define QUE_NODE_FORK       8
#define QUE_NODE_THR        9
#define QUE_NODE_UNDO       10
#define QUE_NODE_COMMIT     11
#define QUE_NODE_ROLLBACK   12
#define QUE_NODE_PURGE      13
#define QUE_NODE_CREATE_TABLE   14
#define QUE_NODE_CREATE_INDEX   15
#define QUE_NODE_SYMBOL     16
#define QUE_NODE_RES_WORD   17
#define QUE_NODE_FUNC       18
#define QUE_NODE_ORDER      19
#define QUE_NODE_PROC       (20 + QUE_NODE_CONTROL_STAT)
#define QUE_NODE_IF     (21 + QUE_NODE_CONTROL_STAT)
#define QUE_NODE_WHILE      (22 + QUE_NODE_CONTROL_STAT)
#define QUE_NODE_ASSIGNMENT 23
#define QUE_NODE_FETCH      24
#define QUE_NODE_OPEN       25
#define QUE_NODE_COL_ASSIGNMENT 26
#define QUE_NODE_FOR        (27 + QUE_NODE_CONTROL_STAT)
#define QUE_NODE_RETURN     28
#define QUE_NODE_ROW_PRINTF 29
#define QUE_NODE_ELSIF      30
#define QUE_NODE_CALL       31
#define QUE_NODE_EXIT       32

```