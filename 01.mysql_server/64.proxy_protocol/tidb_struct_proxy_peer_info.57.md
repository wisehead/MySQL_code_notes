#1.struct proxy_peer_info

```cpp
struct proxy_peer_info
{
  struct sockaddr_storage peer_addr;
  int port;
  bool is_local_command;
};

```