#1.THD::set_proxy_thread_id

```cpp
THD::set_proxy_thread_id
--Global_THD_manager::proxy_reset_thread_id
--m_thread_id= thread_id;
--variables.pseudo_thread_id= m_thread_id;
--thr_lock_info_init
```

#2.caller

```cpp
parse_com_change_user_packet
parse_client_handshake_packet

--read_client_connect_attrs
----read_client_proxy_thread_id
------set_proxy_thread_id
----read_client_proxy_variables
----read_client_proxy_txsql_conn
```