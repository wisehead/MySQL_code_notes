#1.TianmuAttr::RoughCheckBetween

```
TianmuAttr::RoughCheckBetween
--bool is_float = Type().IsFloat();
--auto const &dpn(get_dpn(pack));
--if (!is_float && (v1 > dpn.max_i || v2 < dpn.min_i)) {
    res = common::RoughSetValue::RS_NONE;
  } else if (is_float && (*(double *)&v1 > dpn.max_d || *(double *)&v2 < dpn.min_d)) {
    res = common::RoughSetValue::RS_NONE;
  } else if (!is_float && (v1 <= dpn.min_i && v2 >= dpn.max_i)) {
    res = common::RoughSetValue::RS_ALL;
  } else if (is_float && (*(double *)&v1 <= dpn.min_d && *(double *)&v2 >= dpn.max_d)) {
    res = common::RoughSetValue::RS_ALL;
  } else if ((!is_float && v1 > v2) || (is_float && (*(double *)&v1 > *(double *)&v2))) {
    res = common::RoughSetValue::RS_NONE;
--} else {
----sp = GetFilter_Hist()
----if (res == common::RoughSetValue::RS_SOME)
----sp = GetFilter_Bloom()
```