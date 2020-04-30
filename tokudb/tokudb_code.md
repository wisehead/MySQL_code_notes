#1.tokuFT and tokudb-engine

tokuFT是个支持事务的key/value存储层，tokudb-engine是MySQL API对接层，调用关系为:tokudb-engine ->tokuFT。 
tokuFT里的一个value，在tokudb-engine里就是一条row数据，底层存储与上层调用解耦，是个很棒的设计。 
在tokuFT是个key里，索引的每个node都是大块头(4MB)，node又细分为多个＂小块＂(internal node的叫做partition，leaf node的叫做basement)。 

对于tokudb-engine层的区间操作（比如get_next等），tokuFT这层是无状态的，必须告诉当前的key，然后给你查找next，流程大体是:

```cpp
tokudb-engine::get_next(current_key) 
--> tokuFT::search_next(current_key)
--> tokuFT::return next
```

这样，即使tokuFT缓存了整个node数据，tokudb-engine还是遍历着跟tokuFT要一遍：tokuFT每次都要根据当前key，多次调用compare操作最终查出next，路径太长了！ 
有什么办法优化呢？这就是Bulk Fetch的威力: tokudb-engine向tokuFT一次要回整个node的数据，自己解析出next row数据，tokuFT的调用就省了:

```cpp
 tokudb-engine::get_next(current_key) 
 --> tokudb-engine::parse_next
```

#2.Internal Node
在内存中，TokuDB内节点(internal node)的每个message buffer都有２个重要数据结构：

1) FIFO结构，保存{key, value} 2) OMT结构，保存{key, FIFO-offset} 由于FIFO不具备快速查找特性，就利用OMT来做快速查找(根据key查到value)。

这样，当内节点发生cache miss的时候，索引层需要做：

1) 从磁盘读取节点内容到内存 2) 构造FIFO结构 3) 根据FIFO构造OMT结构(做排序) 由于TokuDB内部有不少性能探(ji)针(shu)，他们发现步骤3)是个不小的性能消耗点，因为每次都要把message buffer做下排序构造出OMT，于是在7.5.0版本，把OMT的FIFO-offset(已排序)也持久化到磁盘，这样排序的损耗就没了。

#3. redo and undo

```cpp
toku_log_enq_insert

```
