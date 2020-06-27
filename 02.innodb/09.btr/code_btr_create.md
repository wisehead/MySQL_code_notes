#1.btr_create

```cpp
caller:
--dict_create_index_tree_step

btr_create
--fseg_create//non-leaf page segment
----fseg_create_general
--fseg_create//for leaf page segment
----fseg_create_general
------fsp_reserve_free_extents
```