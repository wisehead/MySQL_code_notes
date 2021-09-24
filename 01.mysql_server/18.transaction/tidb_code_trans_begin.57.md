#1.trans_begin

```cpp
mysql_execute_command
--trans_begin
----thd->variables.option_bits|= OPTION_BEGIN;
----thd->server_status|= SERVER_STATUS_IN_TRANS;
----

```