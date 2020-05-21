#1.Protocol::send_result_set_metadata
sql/protocol.cc

```cpp
caller:
--JOIN::exec


Protocol::send_result_set_metadata
--my_net_write
--Item_field::make_field
```