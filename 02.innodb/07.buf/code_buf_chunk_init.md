#1.buf_chunk_init

```cpp
buf_chunk_init {
  // 为Buffer Chunks分配一块内存
  chunk->mem_size = mem_size;
  chunk->mem = os_mem_alloc_large(&chunk->mem_size);
   
  // chunk->blocks指向内存的起始点
  // chunk->size是这块内存能保存的数据页的数量，每个数据页需要分配一个buf_block_t descriptor
  chunk->blocks = (buf_block_t*) chunk->mem;
  chunk->size = chunk->mem_size / UNIV_PAGE_SIZE
        - (frame != chunk->mem);
   
  // 将内存块分为两部分，第一部分保存buf_block_t descriptor，第二部分保存数据页的内存
  // 从内存块的起始处开始预留足够多的buf_block_t descriptor（每个数据页分配一个）
  while (frame < (byte*) (chunk->blocks + size)) {
     frame += UNIV_PAGE_SIZE;
     size--;
  }
 
  // 初始化这些buf_block_t ...
  // 并将buf_block_t->frame指向内存块第二部分中为其分配的大小为（UNIV_PAGE_SIZE）的内存区域
  block = chunk->blocks;
  for (i = chunk->size; i--; ) {
    buf_block_init(buf_pool, block, frame);
    block++;
    frame += UNIV_PAGE_SIZE;
    ...
  }
}

```