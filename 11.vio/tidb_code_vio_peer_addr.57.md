#1.vio_peer_addr

```cpp
vio_peer_addr
--if (vio->is_pp)
----*port= vio->pp_port;
----strcpy(ip_buffer, vio->pp_ip);
--if (vio->localhost)
----my_stpcpy(ip_buffer, "127.0.0.1");
----*port= 0;
--else
----mysql_socket_getpeername(vio->mysql_socket, addr, &addr_length)
----vio_get_normalized_ip(addr, addr_length,(struct sockaddr *) &vio->remote, &vio->addrLen);
----vio_getnameinfo((struct sockaddr *) &vio->remote,ip_buffer, ip_buffer_size,port_buffer, NI_MAXSERV,NI_NUMERICHOST | NI_NUMERICSERV);
------getnameinfo
----*port= (uint16) strtol(port_buffer, NULL, 10);
```