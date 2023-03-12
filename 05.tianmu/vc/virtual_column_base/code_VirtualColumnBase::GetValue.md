#1.VirtualColumnBase::getValue

```
VirtualColumnBase::getValue
--ConstColumn::GetValueImpl
----if (core::ATI::IsIntegerType(TypeName()))
------return types::TianmuNum(value_or_null_.Get64(), -1, false, TypeName());
```



