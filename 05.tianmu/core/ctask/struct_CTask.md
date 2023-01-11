#1.struct CTask

```cpp
struct CTask {
  int dwTaskId;     // task id
  int dwPackNum;    // previous task +  this task Actual process pack num
  int dwEndPackno;  // the last packno of this task
  int dwTuple;      // previous task + this task Actual  process tuple
  int dwStartPackno;
  int dwStartTuple;
  int dwEndTuple;
  std::unordered_map<int, int> *dwPack2cur;
  CTask()
      : dwTaskId(0),
        dwPackNum(0),
        dwEndPackno(0),
        dwTuple(0),
        dwStartPackno(0),
        dwStartTuple(0),
        dwEndTuple(0),
        dwPack2cur(nullptr) {}
};
```