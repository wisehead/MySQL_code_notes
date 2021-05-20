#1. trx_start_if_not_started_xa_low


```cpp
trx_start_if_not_started_xa_low
--switch (trx->state)
----case TRX_STATE_NOT_STARTED:
----case TRX_STATE_FORCED_ROLLBACK
------trx_start_low(trx, read_write);
----case TRX_STATE_ACTIVE:
------if (trx->id == 0 && read_write)
--------if (!trx->read_only)
----------trx_set_rw_mode(trx)
--------else if (!srv_read_only_mode)
----------trx_assign_rseg(trx)
----case TRX_STATE_PREPARED:
----case TRX_STATE_COMMITTED_IN_MEMORY:
------break;
```