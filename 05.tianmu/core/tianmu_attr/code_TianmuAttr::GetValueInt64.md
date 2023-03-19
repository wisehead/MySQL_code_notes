#1.TianmuAttr::GetValueInt64

```
GetValueInt64
--auto pack = row2pack(obj);
--const auto &dpn = get_dpn(pack);
--auto p = get_packN(pack);
----return reinterpret_cast<PackInt *>(get_pack(i));
------return reinterpret_cast<Pack *>(get_dpn(i).GetPackPtr() & tag_mask);
--if (!dpn.Trivial()) 
----int inpack = row2offset(obj);
------row % (1L << pss);
----if (p->IsNull(inpack))
------//nothing
----int64_t res = p->GetValInt(inpack);  // 2-level encoding
------return data_[locationInPack];
----res += dpn.min_i;
----return res;
--if (dpn.NullOnly())
----//nothing
--return dpn.min_i;
```