#1.TianmuNum::Assign

```
TianmuNum::Assign
--this->value_ = value;
  this->scale_ = scale;
  this->is_double_ = is_double;
--this->attr_type_ = attrt;
// check if construct decimal, the UNK is used on temp_table.cpp: GetValueString(..)
--if (scale != -1 &&!is_double_) {  
----if ((scale != 0 && attrt != common::ColumnType::BIT) || attrt == common::ColumnType::UNK) {
------is_dot_ = true;
------this->attr_type_ = common::ColumnType::NUM;
--if (is_double_)
----//nothing
--else
----null_ = (value_ == common::NULL_VALUE_64 ? true : false);
```