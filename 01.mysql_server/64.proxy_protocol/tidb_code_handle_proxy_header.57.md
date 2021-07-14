#1.handle_proxy_header

```cpp
handle_proxy_header
--vio_peer_addr
--is_proxy_protocol_allowed
----for (size_t i= 0; i < proxy_protocol_subnet_count; i++)
------addr_matches_subnet(normalized_addr, &proxy_protocol_subnets[i])
--parse_proxy_protocol_header
----memcpy(hdr, preread_bytes, NET_HEADER_SIZE);
----if (have_v1_header)
-------parse_v1_header((char *)hdr, pos, peer_info)
----else
------vio_read(vio, hdr + pos, PROXY_V2_HEADER_LEN - pos);
------parse_v2_header
----if (peer_info->peer_addr.ss_family == AF_INET6)
------vio_get_normalized_ip
--my_snprintf(net->vio->proxy_ip, sizeof(net->vio->proxy_ip), "%s", ip_buffer);
--net->vio->proxy_port= port;
--set_vio_pp_peer_addr
```