#1.Filter::Reset

```
Filter::Reset
--block_changed[b] = 1;
--if (block_status[b] == FB_FULL) {
----//nothing
--if (blocks[b]) {
----if (blocks[b]->Reset(n))
```