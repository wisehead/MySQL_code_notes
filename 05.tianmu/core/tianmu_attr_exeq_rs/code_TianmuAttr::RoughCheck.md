#1.TianmuAttr::RoughCheck

```
TianmuAttr::RoughCheck
--if (d.IsType_AttrValOrAttrValVal()) {
----LoadPackInfo
----auto const &dpn(get_dpn(pack));
------return *m_share->get_dpn_ptr(m_idx[i]);
----if
----} else if (GetPackType() == common::PackType::INT) {
------// common::Operator::O_BETWEEN or common::Operator::O_NOT_BETWEEN
------int64_t v1 = d.val1.vc->GetValueInt64(mit);  // 1-level values; note that these
                                                   // values were already transformed in
                                                   // EncodeCondition
------int64_t v2 = d.val2.vc->GetValueInt64(mit);
------RoughCheckBetween(pack, v1,v2);  // calculate as for common::Operator::O_BETWEEN and then consider negation
--------
```