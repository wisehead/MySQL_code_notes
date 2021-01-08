#1.THD::send_statement_status

```cpp
THD::send_statement_status
--THD::get_stmt_da
--Diagnostics_area::is_sent
--switch (da->status())
----Protocol_classic::send_ok
------net_send_ok
--------if (protocol->has_client_capability(CLIENT_SESSION_TRACK) thd->session_tracker.enabled_any() && thd->session_tracker.changed_any())
----------server_status |= SERVER_SESSION_STATE_CHANGED;
--------Session_tracker::store
----------Transaction_state_tracker::store
--//end switch

```