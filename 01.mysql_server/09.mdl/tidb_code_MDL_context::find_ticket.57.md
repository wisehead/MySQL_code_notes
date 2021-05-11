#1.context::find_ticket

```cpp
MDL_context::find_ticket 这是一个shortcut方法，加锁的时候先检查当前线程是否已持有对应key的MDL锁，并且这个锁的类型不比请求的低，那么就不需要经过MDL系统再分配一个ticket出来（这个比较复杂，代价较高），直接使用已有的ticket，或者clone一个。

举个例子:

1. begin;
2. insert into t1 values (1);
3. insert into t1 values (2);
   ...
在上面的语句序列中，执行语句3的时候就不需要再走一遍复杂的加锁逻辑，因为语句2已经成功拿到t1表的ticket，类型都是MDL_SHARED_WRITE，并且MDL锁时间范围也一样（transaction），这个时候直接用已有的ticket，甚至不用clone。
```