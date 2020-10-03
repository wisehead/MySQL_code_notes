#1.Undo Log Header Page

```cpp
每一个事务的 Undo 日志其实都是一个 FSP Segment，其第一个页就是【Undo Log Header Page】

每一个 Slot 地址指向的就是一个【Undo Log Header Page】（注意是“Header Page”（是一个Page），不是“Page Header”（是一个Header））

是存储 Undo Record 的页面类型之一（另一个为 Normal Undo Page）
每一个 Undo Log Header Page 同一时刻只隶属于同一活跃事务。Undo Log Header Page 可以同时保存若干个已提交事务+一个活跃事务
每一个 Undo Log Header Page 同一时刻要么是 “TRX_UNDO_INSERT”（只保存INSERT产生的Undo Record），要么是 “TRX_UNDO_UPDATE”（只保存UPDATE/DELETE产生的Undo Record）；主要是为了分类回收
一个事务如果既有INSERT又有UPDATE/DELETE，那么会占有两个 Undo Log Header Page（也即占有两个 Slot）
每个 Undo Log Header Page 独占一个 File Segment（分配 INODE entry，有若干个 Extent List ...）

存储内容：

Undo Page Header：每一个存放 undo log 的数据页都有的 header
Undo Segment Header：只有一个 undo log segment 才有的 header，对应于使用该 undo log segment 的事务
若干“事务级别”Header：其中每一个事务都由“【Undo Log Header】 + 日志记录内容”组成

```