#1.TianmuAttr::GetNotNullValueString

```
TianmuAttr::GetNotNullValueString
--int pack = row2pack(obj);
--offset = row2offset(obj);
--if (GetPackType() == common::PackType::STR)
----auto cur_pack = get_packS(pack);
------return reinterpret_cast<PackStr *>(get_pack(i)); 
--------TianmuAttr::get_pack
----return cur_pack->GetValueBinary(offset);
------PackStr::GetValueBinary
```