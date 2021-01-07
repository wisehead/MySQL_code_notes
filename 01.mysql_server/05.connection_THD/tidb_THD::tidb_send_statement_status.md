#1.THD::send_statement_status

```cpp
THD::send_statement_status
--THD::get_stmt_da
--Diagnostics_area::is_sent
--switch (da->status())
----Protocol_classic::send_ok
------net_send_ok
--//end switch

```