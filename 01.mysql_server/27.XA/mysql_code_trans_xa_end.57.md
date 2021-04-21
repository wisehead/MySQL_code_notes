#1.trans_xa_end

```cpp
trans_xa_end
--xid_state= thd->get_transaction()->xid_state();
--xid_state->set_state(XID_STATE::XA_IDLE);
```