#1.btr_page_free

```cpp
btr_page_free
--btr_page_free_low
----buf_block_modify_clock_inc
----btr_root_get
----fseg_free_page
------fseg_inode_get
--------fseg_inode_try_get
----------inode_addr.page = mach_read_from_4(header + FSEG_HDR_PAGE_NO);
----------inode_addr.boffset = mach_read_from_2(header + FSEG_HDR_OFFSET);
----------fut_get_ptr(space, zip_size, inode_addr, RW_SX_LATCH, mtr);
------------buf_block_get_frame(block) + addr.boffset
------fseg_free_page_low
--------btr_search_drop_page_hash_when_freed
--------xdes_get_descriptor
----------xdes_get_descriptor_with_space_hdr
------------ut_2pow_round(offset, UNIV_PAGE_SIZE)
--------------#define ut_2pow_round(n, m) ((n) & ~((m) - 1))
----------return(descr_page + XDES_ARR_OFFSET+ XDES_SIZE * xdes_calc_descriptor_index(zip_size, offset));
------------ut_2pow_remainder(offset, UNIV_PAGE_SIZE)/ FSP_EXTENT_SIZE);
--------------#define ut_2pow_remainder(n, m) ((n) & ((m) - 1))
--------xdes_mtr_get_bit
----------xdes_get_bit
------------ut_bit_get_nth(mach_read_ulint(descr + XDES_BITMAP + byte_index,MLOG_1BYTE),bit_index));
--------xdes_get_state
--------xdes_is_full
----------xdes_get_n_used
--------mlog_write_ulint(seg_inode + FSEG_NOT_FULL_N_USED,not_full_n_used - 1, MLOG_4BYTES, mtr);
--------xdes_set_bit(descr, XDES_FREE_BIT, page % FSP_EXTENT_SIZE, TRUE, mtr);
--------xdes_set_bit(descr, XDES_CLEAN_BIT, page % FSP_EXTENT_SIZE, TRUE, mtr);
--------xdes_is_free
--------mtr->n_freed_pages++;

```