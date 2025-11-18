#1.Undo Log Normal Page

```cpp
当活跃事务产生的 undo record 超过 Undo Log Header Page 容量后，单独再为此事务分配 Normal Undo Page（trx_undo_add_page）

实际存储 undo records 的页面类型之一（另一个是 Undo Log Header Page）
Normal Undo Page 只隶属于一个事务
包含 Undo Page Header 和 Undo Segment Header
不包含 Undo Log Header，只是存储“溢出”的 undo records
```