#1.Filter::Block::Reset

```
Filter::Block::Reset
--uint mask = lshift1[n & 31];
--uint &cur_bl = block_table[n >> 5];
--if (cur_bl & mask) {  // if this operation change value
----//--no_set_bits;
----cur_bl &= ~mask;
--return (no_set_bits == 0);

```