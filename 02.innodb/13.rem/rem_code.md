#1. rec_get_offsets_func

```cpp
caller:
--cmp_dtuple_rec_with_match_low

rec_get_offsets_func
--rec_offs_n_fields
--rec_init_offsets
----offs = REC_N_OLD_EXTRA_BYTES;
----offs += rec_offs_n_fields(offsets);//n_fields = offsets[1];
------offsets[0]=100, offsets[1]=1
----*rec_offs_base(offsets) = offs;
------offsets + REC_OFFS_HEADER_SIZE = offsets[2] = offs;
----rec_1_get_field_end_info//return(mach_read_from_1(rec - (REC_N_OLD_EXTRA_BYTES + n + 1)));
------//可以看出old rec的格式各个列是逆序存储的。
----rec_offs_base(offsets)[1 + i] = offs;

```

#2.cmp_dtuple_rec_with_match_low

```cpp
caller:
--page_cur_search_with_match

/*************************************************************//**
This function is used to compare a data tuple to a physical record.
Only dtuple->n_fields_cmp first fields are taken into account for
the data tuple! If we denote by n = n_fields_cmp, then rec must
have either m >= n fields, or it must differ from dtuple in some of
the m fields rec has. If rec has an externally stored field we do not
compare it but return with value 0 if such a comparison should be
made.
@return 1, 0, -1, if dtuple is greater, equal, less than rec,
respectively, when only the common first fields are compared, or until
the first externally stored field in rec */

cmp_dtuple_rec_with_match_low
--rec_offs_comp
----return(*rec_offs_base(offsets) & REC_OFFS_COMPACT);
--rec_get_info_bits
--dtuple_get_info_bits
--dtuple_get_nth_field
--rec_get_nth_field
--cmp_collate
```