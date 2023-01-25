#1.PackStr::GetValueBinary

```
PackStr::GetValueBinary
--if (IsNull(locationInPack))
----return types::BString();
--if (data_.len_mode == sizeof(ushort))
----str_size = data_.lens16[locationInPack];
--return types::BString(data_.index[locationInPack], str_size);
```