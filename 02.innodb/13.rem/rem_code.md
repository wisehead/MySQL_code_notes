#1.rec_offs_n_fields

```cpp
caller:
--page_cur_search_with_match

rec_offs_n_fields
--offs = REC_N_OLD_EXTRA_BYTES;
--offs += rec_offs_n_fields(offsets);//n_fields = offsets[1];
----offsets[0]=100, offsets[1]=1
--*rec_offs_base(offsets) = offs;
----offsets + REC_OFFS_HEADER_SIZE = offsets[2] = offs;
--rec_1_get_field_end_info//return(mach_read_from_1(rec - (REC_N_OLD_EXTRA_BYTES + n + 1)));
----//可以看出old rec的格式各个列是逆序存储的。
--rec_offs_base(offsets)[1 + i] = offs;

```