#1.VCPackGuardian::UnlockAllOnLockOneByThread

```
VCPackGuardian::UnlockAllOnLockOneByThread
--const auto &var_map = my_vc_.GetVarMap();
--auto iter_thread = last_pack_thread_.find(thread_id);
--for (auto const &iter : var_map) {
----int cur_dim = iter.dim;
----int col_index = iter.col_ndx;
----auto iter_pack = iter_thread->second.find(cur_dim);
----auto iter_val = iter_pack->second.find(col_index);
----int cur_pack = iter_val->second;
----iter_pack->second.erase(col_index);
----iter.GetTabPtr()->UnlockPackFromUse(col_index, cur_pack);
```