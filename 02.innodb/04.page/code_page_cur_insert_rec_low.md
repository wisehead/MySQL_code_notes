#1.page_cur_insert_rec_low

```cpp
caller:
--page_cur_tuple_insert

page_cur_insert_rec_low
--rec_offs_size
----rec_offs_data_size
------rec_offs_base(offsets)[rec_offs_n_fields(offsets)] & REC_OFFS_MASK;
--rec_copy
--page_rec_get_next
----page_rec_get_next_low
------rec_get_next_offs
--page_rec_set_next
----rec_set_next_offs_new
--page_header_set_field(page, NULL, PAGE_N_RECS, 1 + page_get_n_recs(page));
--rec_set_n_owned_new
----rec_set_bit_field_1
--rec_set_heap_no_new
--page_header_get_ptr(page, PAGE_LAST_INSERT)
----page_header_get_offs
--page_header_set_ptr(page, NULL, PAGE_LAST_INSERT, insert_rec);
--page_rec_find_owner_rec
----page_rec_get_next
--rec_set_n_owned_new(owner_rec, NULL, n_owned + 1);
--page_cur_insert_rec_write_log
----rec_get_offsets_func
------rec_init_offsets
--------rec_init_offsets_comp_ordinary
----------rec_init_null_and_len_comp
----rec_offs_extra_size
----mlog_open_and_write_index
------mlog_open
------mlog_write_initial_log_record_fast
--------mlog_write_initial_log_record_low
----------mtr_t::set_rec_body_offset
----------mtr_t::set_len_ptr
```



#2.offset

```cpp
offset[0] REC_OFFS_NORMAL_SIZE=100, offset数组默认大小100字节
offset[1] 长度
offsets[2] = (ulint)rec;
offsets[3] = (ulint)index;
offset[4] = REC_N_NEW_EXTRA_BYTES | REC_OFFS_COMPACT;标记位
*rec_offs_base(offsets) = (rec - (lens + 1)) | REC_OFFS_COMPACT | any_ext;
offset[5] = 8;//infimum/supremum
```

#3.redo log

```cpp

这个只是普通的row record.
变长字段长度列表|Null 字段标志位|info_bits(4bit)|n_owned(4bit)|order(13bit)|rec type(3bit)|next record offset|主键（用户指定或者缺省6） | Trx_id（6Byte） | ROLL_PTR（7B） | FIELD1 | FIELD2|.......|FIELDN| 

REC_N_NEW_EXTRA_BYTES = 5B，NEW
```

#4 gaiaDB redo log

```cpp
COM_INSERT
type（1B） | space(1~5)|page_no（1~5）| Body_len | field_num(2B)| index_field(2B)| len1 | len2 | ..... | lenN | page_offset(cursor_rec)（2B）| 2 * (rec_size - i) + 1 （1~5）| info byte(1B) |  extra_size（1~5） | mismatch_size（1~5）|

```