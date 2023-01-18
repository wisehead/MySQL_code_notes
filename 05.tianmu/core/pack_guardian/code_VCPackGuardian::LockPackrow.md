#1.VCPackGuardian::LockPackrow

```cpp
VCPackGuardian::LockPackrow
--int threadId = mit.GetTaskId();
--int taskNum = mit.GetTaskNum();
--VCPackGuardian::Initialize
----VCPackGuardian::UnlockAll
--if (initialized_ && (taskNum > guardian_threads_)) {
      // recheck to make sure last_pack_ is not overflow
----ResizeLastPack(taskNum);
--for (auto iter = my_vc_.GetVarMap().cbegin(); iter != my_vc_.GetVarMap().cend(); iter++) 
----if (last_pack_[cur_dim][threadId] != mit.GetCurPackrow(cur_dim)) 
------if (last_pack_[cur_dim][threadId] != common::NULL_VALUE_32)
--------tab->UnlockPackFromUse(iter->col_ndx, last_pack_[cur_dim][threadId]);
------tab->LockPackForUse(iter->col_ndx, mit.GetCurPackrow(cur_dim));
--------TianmuTable::LockPackInfoForUse
```

#2.caller

```
LockSourcePacks
--VCPackGuardian::LockPackrow
```