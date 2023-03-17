#1.VCPackGuardian::LockPackrowOnLockOneByThread

```
VCPackGuardian::LockPackrowOnLockOneByThread
--auto &var_map = my_vc_.GetVarMap();
--thread_id = pthread_self();
--iter_thread = last_pack_thread_.find(thread_id);
--for (auto iter = var_map.cbegin(); iter != var_map.cend(); iter++) {
----int cur_dim = iter->dim;
----int col_index = iter->col_ndx;
----int cur_pack = mit.GetCurPackrow(cur_dim);
----JustATable *tab = iter->GetTabPtr().get();

----if (has_myself_thread) {
------auto iter_dim = iter_thread->second.find(cur_dim);
------if (iter_thread->second.end() != iter_dim) {
--------auto iter_index = iter_dim->second.find(col_index);
--------if (iter_dim->second.end() != iter_index) {
----------int last_pack = iter_index->second;
----------if (last_pack == cur_pack) {
            continue;
          }

----------iter_dim->second.erase(col_index);
----------tab->UnlockPackFromUse(col_index, last_pack);

----tab->LockPackForUse(col_index, cur_pack);
--//更新last_pack_thread_，记录所有的正在加锁的pack。
--for (auto iter = var_map.cbegin(); iter != var_map.cend(); iter++) {
    if (!iter->GetTabPtr()) {
      continue;
    }

    int cur_dim = iter->dim;
    int col_index = iter->col_ndx;
    int cur_pack = mit.GetCurPackrow(cur_dim);

    {
      if (has_myself_thread) {
        auto iter_dim = iter_thread->second.find(cur_dim);
        if (iter_thread->second.end() != iter_dim) {
          auto iter_index = iter_dim->second.find(col_index);
          if (iter_dim->second.end() != iter_index) {
            int last_pack = iter_index->second;
            if (last_pack == cur_pack) {
              continue;
            }
          }
        }
      }
    }

    if (!has_myself_thread) {
      std::unordered_map<int, std::unordered_map<int, int>> pack_value;
      auto &lock_dim = pack_value[cur_dim];
      lock_dim[col_index] = cur_pack;

      {
        std::scoped_lock lock(mx_thread_);
        last_pack_thread_[thread_id] = std::move(pack_value);
      }
    } else {
      auto &lock_thread = last_pack_thread_[thread_id];
      auto &lock_dim = lock_thread[cur_dim];
      lock_dim[col_index] = cur_pack;
    }
```