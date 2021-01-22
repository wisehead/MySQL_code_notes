#1.kill

```cpp
do_command
--Protocol_classic::get_command
----Protocol_classic::read_packet
------my_net_read
--------net_read_packet
----------net_read_packet_header
------------count= NET_HEADER_SIZE
------------net_read_raw_loop
--------------buf= net->buff + net->where_b
--------------vio_read
----------------inline_mysql_socket_recv
------------------recv(mysql_socket.fd, buf, IF_WIN((int),) n, flags)
------------pkt_nr= net->buff[net->where_b + 3]
----------pkt_len= uint3korr(net->buff+net->where_b)
----------net_read_raw_loop//read package body
------------vio_read
------raw_packet= m_thd->net.read_pos
----*cmd= (enum enum_server_command) raw_packet[0];
----Protocol_classic::parse_packet
------data->com_query.query= reinterpret_cast<const char*>(raw_packet);
------data->com_query.length= packet_length

```