#1.trans_register_ha

```cpp
/**
  Register a storage engine for a transaction.

  Every storage engine MUST call this function when it starts
  a transaction or a statement (that is it must be called both for the
  "beginning of transaction" and "beginning of statement").
  Only storage engines registered for the transaction/statement
  will know when to commit/rollback it.

  @note
    trans_register_ha is idempotent - storage engine may register many
    times per transaction.

*/
trans_register_ha
--Transaction_ctx *trn_ctx= thd->get_transaction();
--Ha_trx_info *knownn_trans= trn_ctx->ha_trx_info(trx_scope);
```