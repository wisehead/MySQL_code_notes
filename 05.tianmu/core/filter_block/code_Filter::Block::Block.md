#1.Filter::Block::Block

```
Filter::Block::Block
--this->owner = owner;
--no_obj = _no_obj;
--block_size = (NumOfObj() + 31) / 32;
--block_table = (uint *)owner->bit_block_pool->malloc();
----boost::pool::malloc
--if (all_full) {
----std::memset(block_table, 255, Filter::bitBlockSize);
----no_set_bits = no_obj;  // Note: when the block is full, the overflow occurs
                           // and no_set_bits=0.
                           
```