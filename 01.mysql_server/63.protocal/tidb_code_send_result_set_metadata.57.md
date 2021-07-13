#1.send_result_set_metadata

```cpp
caller:
--JOIN::exec

Query_result_send::send_result_set_metadata
--THD::send_result_metadata
----Protocol_classic::start_result_metadata
------if (flags & Protocol::SEND_NUM_ROWS)
--------net_store_length((uchar *) &tmp, num_cols);
--------my_net_write
----while ((item= it++))
------Item::make_field
------Protocol_text::start_row
------Protocol_classic::send_field_metadata//store Column Definition. 12 bytes
------Protocol_classic::end_row
--------my_net_write
----Protocol_classic::end_result_metadata
```