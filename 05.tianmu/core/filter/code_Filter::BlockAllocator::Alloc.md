#1.Filter::BlockAllocator::Alloc

```
Filter::BlockAllocator::Alloc
--if (sync)
----block_mut.lock();
--if (!free_in_pool) {
----pool[i] = (Filter::Block *)block_object_pool.malloc();
------boost::pool:malloc()
----free_in_pool = pool_size;
----next_ndx = 0;
--free_in_pool--;
--Block *b = pool[next_ndx];
--next_ndx = (next_ndx + pool_stride) % pool_size;
--if (sync)
----block_mut.unlock();
--return b;
```