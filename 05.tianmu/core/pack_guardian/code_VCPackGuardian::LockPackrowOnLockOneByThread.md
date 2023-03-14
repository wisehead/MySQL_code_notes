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
```