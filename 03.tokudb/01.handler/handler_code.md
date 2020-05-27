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