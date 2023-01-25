#1.TianmuAttr::IsNull

```
TianmuAttr::IsNull
--if (obj == common::NULL_VALUE_64)
----return true;
--pack = row2pack(obj);
--&dpn = get_dpn(pack);
----*m_share->get_dpn_ptr(m_idx[i]);
------return &start[i];
```
