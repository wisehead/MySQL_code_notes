#1.pull_out_semijoin_tables

```cpp
/*
3.pull_out_semijoin_tables，拉出半连接中的表变为引用关系

pull_out_semijoin_tables函数基于“功能依赖”，从半连接中拉出一些表作为引用关系存在（引用关系相当于指针，使得原位置不存放对象，而是一个地址式的指针，用eq_ref指向真正对象）。

那么什么是“功能依赖”呢？先看下边的代码：
WHERE oe IN (SELECT it1.primary_key WHERE p(it1, it2) ... )


it1.primary_key=oe表示功能依赖，表it1可以被“拉出”，因为主键能够保证
it1.primary_key=oe式的操作能使用eq_ref数据访问方式被访问到。

拉出半连接的表带来的影响是：不能再利用物化或松散扫描来优化半连接。

由图13-24可知，pull_out_semijoin_tables函数被make_join_statistics函数唯一调用，用以化简半连接操作。
*/
```