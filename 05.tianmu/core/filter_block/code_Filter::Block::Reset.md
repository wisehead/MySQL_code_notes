#1.Filter::Block::Reset

```
Filter::Block::Reset
--int bl1 = n1 / 32;
--int bl2 = n2 / 32;
--int off1 = (n1 & 31);
--int off2 = (n2 & 31);
--if (no_set_bits == no_obj) {  // just created as full
----if (bl1 == bl2) {
------for (int i = off1; i <= off2; i++) block_table[bl1] &= ~lshift1[i];
----no_set_bits = no_obj - (n2 - n1 + 1);
--return (no_set_bits == 0);
```