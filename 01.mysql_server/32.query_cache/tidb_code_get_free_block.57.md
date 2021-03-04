#1.get_free_block

```cpp
caller:
- allocate_block
- join_results

get_free_block
--start = find_bin(len)
--//从小到大找看看在规定循环次数内能不能找到
--//从大到小再找一遍
--if (block == 0 && start > 0)//当前的bin无法满足要求
----//去前一个大点的bin找找看
--if (block == 0 && ! not_less)//还是没找到,从前面的bin里找不到
----//从后面的bin里找
--if (block != 0)
----exclude_from_free_memory_list
------double_linked_list_exclude
------bin->number--;
------free_memory-=free_block->length;
------free_memory_blocks--;

```