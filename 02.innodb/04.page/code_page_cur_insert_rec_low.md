#1.page_cur_insert_rec_low

```cpp
caller:
--page_cur_tuple_insert

page_cur_insert_rec_low
--rec_offs_size
----rec_offs_data_size
------rec_offs_base(offsets)[rec_offs_n_fields(offsets)] & REC_OFFS_MASK;
--rec_copy

```