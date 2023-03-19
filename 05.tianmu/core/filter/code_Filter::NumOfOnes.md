#1. Filter::NumOfOnes

```
Filter::NumOfOnes
--int64_t count = 0;
--for (size_t b = 0; b < no_blocks; b++) {
    if (block_status[b] == FB_FULL)
      count += int(block_last_one[b]) + 1;
    else if (blocks[b])
      count += blocks[b]->NumOfOnes();  // else empty
  }
--return count; 
```