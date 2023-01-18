#1.VCPackGuardian::Initialize

```
VCPackGuardian::Initialize
--VCPackGuardian::UnlockAll();
--last_pack_.clear();
--guardian_threads_ = no_th;
--int no_dims = -1;
--for (auto const &iter : my_vc_.GetVarMap())
----if (iter.dim > no_dims)
------no_dims = iter.dim;  // find the maximal number of dimension used
--no_dims++;
--if (no_dims > 0) {  // else constant
----last_pack_.reserve(no_dims);
----for (int i = 0; i < no_dims; ++i) last_pack_.emplace_back(guardian_threads_, common::NULL_VALUE_32);
--initialized_ = true;
```