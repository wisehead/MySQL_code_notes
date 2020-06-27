#1.btr_create

```cpp
caller:
--dict_create_index_tree_step

btr_create
--fseg_create//non-leaf page segment
----fseg_create_general
------fsp_reserve_free_extents
--------fsp_reserve_free_pages
----------xdes_get_descriptor_with_space_hdr
------------xdes_calc_descriptor_page
--fseg_create//for leaf page segment
----fseg_create_general
------fsp_reserve_free_extents
```