#1.MDL_context::clone_ticket

```cpp
MDL_context::clone_ticket 经过检测发现可以直接使用已有的ticket，比如上面的MDL_context::find_ticket发现了可以复用的ticket，但是锁时间范围不一致，为了确保已经有锁释放时，不影响现在请求的，就clone一个ticket。

1. begin;
2. insert into t1 values (1);
3. handler t1 open;
   ...
在上面的语句序列中，执行语句3的时候，发现有可以复用的ticket（语句2的ticket），但是handler需要的MDL锁是显式的，而语句2取得的ticket是事务时间范围的，事务完成后就会释放，为了避免handler的MDL锁被提前释放，因此单独clone一个出来用。
```