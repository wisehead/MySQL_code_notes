#1.Query_result_send::send_data

```cpp
caller:
--JOIN::exec

Query_result_send::send_data
--Protocol_text::start_row
--THD::send_result_set_row
----for (Item *item= it++; item; item= it++)
------Item::send
--------Item_string::val_str
--------Protocol_text::store//wrapper
----------Protocol_text::store
------------Protocol_classic::store_string_aux
--------------Protocol_classic::net_store_data
----------------copy_and_convert
----------------net_store_length
----//end for
--Protocol_classic::end_row
----my_net_write

```