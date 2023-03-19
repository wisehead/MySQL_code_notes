#1.Filter::ResetBetween

```
Filter::ResetBetween
--if (b1 == b2) {
----if (block_status[b1] == FB_FULL) {
------if (n1 > 0 && n2 >= block_last_one[b1]) {
--------//nothing
------} else if (n1 == 0 && n2 >= block_last_one[b1]) {
--------//nothing
------else
--------int new_block_size = (b1 == no_blocks - 1 ? no_of_bits_in_last_block : pack_def);
--------blocks[b1] = block_allocator->Alloc();
--------
```