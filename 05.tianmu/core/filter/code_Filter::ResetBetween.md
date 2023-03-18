#1.Filter::ResetBetween

```
Filter::ResetBetween
--if (block_status[b] == FB_FULL) {
----if (static_cast<size_t>(delayed_block) != b) {
------Commit();
------delayed_block = b;
------delayed_stats = -1;
----if (pos == delayed_stats + 1) {
------delayed_stats++;
```