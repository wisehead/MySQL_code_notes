#1. TianmuAttr::MaxStringSize

```
TianmuAttr::MaxStringSize
--LoadPackInfo
--if (Type().Lookup()) {
----//nothing
--else
----for (uint b = 0; b < SizeOfPack(); b++) {
------cur_size = GetActualSize(b);
------if (max_size < cur_size)
--------max_size = cur_size;
------if (max_size == Type().GetPrecision())
--------break;
```