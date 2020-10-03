#1.enum trx_state_t

```cpp
/** Transaction states (trx_t::state) */
enum trx_state_t {
    TRX_STATE_NOT_STARTED,
    TRX_STATE_ACTIVE,
    TRX_STATE_PREPARED,         /* Support for 2PC/XA */
    TRX_STATE_COMMITTED_IN_MEMORY
};
```