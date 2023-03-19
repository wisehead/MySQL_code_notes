#1.Filter::Commit

```
Filter::Commit
--if (delayed_block > -1) {
----if (block_status[delayed_block] == FB_FULL && delayed_stats >= 0)
------ResetBetween(delayed_block, 0, delayed_block, delayed_stats);
----delayed_block = -1;
----delayed_stats = -1;
--if (delayed_block_set > -1) {
----//nothing
```