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

#2.OK_packet

```cpp
(gdb) x /20xb packet
0x7f30843c52a0: 0x00    0x01    0x00    0x03    0x40    0x00    0x00    0x00
                                 |                        |                                     |
                                 header   |        last_insert_id       warnings(2)
affected_rows  |
               status_flags
0x7f30843c52a8: 0x0b    0x05    0x09    0x08    0x54    0x5f    0x5f    0x5f
                                |                        |             |            |           |           |            |
                                length .   | .      9           8           T .       _ .        _          _
                                              SESSION_TRACK_TRANSACTION_STATE

0x7f30843c52b0: 0x57    0x5f    0x53    0x5f
                                |            |            |           |
                               W .       _           S         _
```