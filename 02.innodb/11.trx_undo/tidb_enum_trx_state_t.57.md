#1.enum trx_state_t

```cpp
/** Transaction states (trx_t::state) */
enum trx_state_t {

        TRX_STATE_NOT_STARTED,

        /** Same as not started but with additional semantics that it
        was rolled back asynchronously the last time it was active. */
        TRX_STATE_FORCED_ROLLBACK,

        TRX_STATE_ACTIVE,

        /** Support for 2PC/XA */
        TRX_STATE_PREPARED,

        TRX_STATE_COMMITTED_IN_MEMORY
};
```