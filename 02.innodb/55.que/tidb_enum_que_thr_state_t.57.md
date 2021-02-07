#1.enum que_thr_state_t

```cpp
/** Query thread states */
enum que_thr_state_t {
    QUE_THR_RUNNING,
    QUE_THR_PROCEDURE_WAIT,
    /** in selects this means that the thread is at the end of its
    result set (or start, in case of a scroll cursor); in other
    statements, this means the thread has done its task */
    QUE_THR_COMPLETED,
    QUE_THR_COMMAND_WAIT,
    QUE_THR_LOCK_WAIT,
    QUE_THR_SUSPENDED
};
```