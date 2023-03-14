#1.TianmuNum::ToDecimal

```
TianmuNum::ToDecimal
--if (is_double_) {
--else
----tmpv = this->value_;
----tmpp = this->scale_;
----if (scale != -1) {
------tmpv *= (int64_t)Uint64PowOfTen(scale - tmpp);
--return TianmuNum(tmpv * sign, tmpp);
```