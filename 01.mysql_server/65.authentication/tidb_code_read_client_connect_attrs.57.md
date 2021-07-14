#1. read_client_connect_attrs


```cpp
read_client_connect_attrs
--if (COM_CHANGE_USER == command)
----read_client_proxy_reset_user
------read_client_proxy_reset_user_ip
--------strcpy(mpvio->thd->net.vio->pp_ip, buffer);
------read_client_proxy_reset_user_port
--------mpvio->thd->net.vio->pp_port= (uint16_t)port;
--read_client_proxy_thread_id(mpvio, *ptr, length);
--read_client_proxy_variables(mpvio, *ptr, length);
----alloc_query
----execute_sql_inner
--read_client_proxy_txsql_conn(mpvio, *ptr, length);

```