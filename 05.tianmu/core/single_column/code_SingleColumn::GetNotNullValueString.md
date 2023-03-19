#1.SingleColumn::GetNotNullValueString

```
GetNotNullValueString
--col_->GetNotNullValueString(mit[dim_], s);
----TianmuAttr::GetNotNullValueString
------int pack = row2pack(obj);
------int offset = row2offset(obj);
------if (GetPackType() == common::PackType::STR) {
--------auto cur_pack = get_packS(pack);
----------TianmuAttr::get_pack//get DP pointer
--------return cur_pack->GetValueBinary(offset);
```