#1. has_proxy_protocol_header

```cpp
has_proxy_protocol_header
--preread_bytes= net->buff + net->where_b;
--!memcmp(preread_bytes, PROXY_PROTOCOL_V1_SIGNATURE, NET_HEADER_SIZE)||!memcmp(preread_bytes, PROXY_PROTOCOL_V2_SIGNATURE, NET_HEADER_SIZE);
```

#2.caller

`net_read_packet_header
`