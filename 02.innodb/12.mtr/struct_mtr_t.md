#1.struct mtr_t

```cpp
struct mtr_t{
  // dyn_array_t是动态数组，可以简单的理解为"STL vector"，每一个元素称为一个slot
   
  // memo 保存的是修改的所有的Page：
  //   1) 当准备修改Page之前需要获得Page latch
  //   2) 调用mtr_memo_push(mtr, page, lock_type)将Page放入memo（动态数组）
  //      放入memo的是一个mtr_memo_slot_t*，保存着（buf_block_t*, lock_type）
  //   3) 当mtr commit时，调用mtr_memo_pop_all，遍历所有的slot，根据保存的不同的锁类型（lock_type）释放每个
  //      Page latch（详见mtr_memo_slot_release_func）
  dyn_array_t memo;
  // log 保存的是生成的所有redo log records，当mtr commit时将mtr的全部日志写入公共的Redo
  // buffer （log_sys->buf）中
  dyn_array_t log;
  ...
}
```