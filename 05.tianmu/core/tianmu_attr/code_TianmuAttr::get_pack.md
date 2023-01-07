#1.TianmuAttr::get_pack

```
TianmuAttr::get_pack
--return reinterpret_cast<Pack *>(get_dpn(i).GetPackPtr() & tag_mask);
----DPN::GetPackPtr
------tagged_ptr.load();
```