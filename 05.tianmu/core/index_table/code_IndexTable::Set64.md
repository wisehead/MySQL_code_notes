#1.IndexTable::Set64

```
IndexTable::Set64
--int b = int(n >> block_shift);
--if (b != cur_block)
----LoadBlock(b);
--block_changed = true;
--if (bytes_per_value == 4)
      ((unsigned int *)buf)[n & block_mask] = (unsigned int)val;
--else if (bytes_per_value == 8)
      ((uint64_t *)buf)[n & block_mask] = val;
--else  // bytes_per_value == 2
      ((unsigned short *)buf)[n & block_mask] = (unsigned short)val;
```