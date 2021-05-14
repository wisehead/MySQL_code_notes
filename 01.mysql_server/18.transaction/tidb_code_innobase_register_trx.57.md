#1.innobase_register_trx

```cpp
innobase_register_trx
--trans_register_ha
----Transaction_ctx::enum_trx_scope trx_scope=all ? Transaction_ctx::SESSION : Transaction_ctx::STMT;
----Ha_trx_info *knownn_trans= trn_ctx->ha_trx_info(trx_scope);
------thd->m_transaction->m_scope_info[scope].m_ha_list
----ha_info= thd->ha_data[ht_arg->slot].ha_info + (all ? 1 : 0);
----ha_info->register_ha(knownn_trans, ht_arg);
----trn_ctx->set_ha_trx_info(trx_scope, ha_info);
```