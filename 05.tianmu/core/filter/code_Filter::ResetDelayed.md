#1.Filter::ResetDelayed

```
Filter::ResetBetween
--if (block_status[b] == FB_FULL) {
----if (static_cast<size_t>(delayed_block) != b) {
------Commit();
------delayed_block = b;
------delayed_stats = -1;
----if (pos == delayed_stats + 1) {
------delayed_stats++;
----} else if (pos > delayed_stats + 1) {  // then we can't delay
------if (delayed_stats >= 0)
--------ResetBetween(b, 0, b, delayed_stats);
------Reset(b, pos);
------delayed_stats = -2;  // not to use any longer
```