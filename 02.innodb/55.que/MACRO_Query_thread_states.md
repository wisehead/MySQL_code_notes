#1.MACRO Query thread states

```cpp
/* Query thread states */
#define QUE_THR_RUNNING     1
#define QUE_THR_PROCEDURE_WAIT  2
#define QUE_THR_COMPLETED   3   /* in selects this means that the
                    thread is at the end of its result set
                    (or start, in case of a scroll cursor);
                    in other statements, this means the
                    thread has done its task */
#define QUE_THR_COMMAND_WAIT    4
#define QUE_THR_LOCK_WAIT   5
#define QUE_THR_SUSPENDED   7
#define QUE_THR_ERROR       8

```