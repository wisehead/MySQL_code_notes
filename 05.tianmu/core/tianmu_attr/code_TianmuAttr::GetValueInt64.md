#1.TianmuAttr::GetValueInt64

```
GetValueInt64
--auto pack = row2pack(obj);
--const auto &dpn = get_dpn(pack);
--auto p = get_packN(pack);
----return reinterpret_cast<PackInt *>(get_pack(i));
------return reinterpret_cast<Pack *>(get_dpn(i).GetPackPtr() & tag_mask);
--if (!dpn.Trivial()) 
----//
--if (dpn.NullOnly())
----//
--return dpn.min_i;
```