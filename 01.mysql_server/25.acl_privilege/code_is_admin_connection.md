#1.is_admin_connection

```cpp
class THD;
bool is_admin_connection() const { return m_is_admin_conn; }
```

#2.set_admin_connection

```cpp
class THD;
  Channel_info_tcpip_socket(MYSQL_SOCKET connect_socket, bool is_admin_conn)
      : m_connect_sock(connect_socket), m_is_admin_conn(is_admin_conn) {}

  virtual THD *create_thd() {
    THD *thd = Channel_info::create_thd();

    if (thd != NULL) {
      thd->set_admin_connection(m_is_admin_conn);
      init_net_server_extension(thd);
    }
    return thd;
  }
```

#3. Channel_info_tcpip_socket

```cpp
caller:
--handle_admin_socket
--Mysqld_socket_listener::listen_for_connection_event
```