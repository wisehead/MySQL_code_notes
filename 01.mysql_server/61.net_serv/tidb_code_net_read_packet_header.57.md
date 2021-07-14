#1.net_read_packet_header

```cpp
net_read_packet_header
--if (pkt_nr != (uchar) net->pkt_nr)
----if (has_proxy_protocol_header(net))
------return TRUE;
----my_error(ER_NET_PACKETS_OUT_OF_ORDER, MYF(0));
----return TRUE;

```

#2.caller

```cpp
my_net_read
--net_read_packet
```

#3.