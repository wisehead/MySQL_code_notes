#1.Protocol::send_result_set_metadata
sql/protocol.cc

```cpp
caller:
--JOIN::exec


Protocol::send_result_set_metadata
--my_net_write
--Item_field::make_field
--prepare_for_resend
--store
----Protocol::store_string_aux
------net_store_data
--------copy_and_convert
----------my_convert
--write
----my_net_write
--write_eof_packet
```

#2.Protocol_text::store

```cpp
caller:
--Item_field::send


Protocol_text::store
--val_str
----Field_long::val_str
------longget
------my_long10_to_str_8bit
--store_string_aux
```