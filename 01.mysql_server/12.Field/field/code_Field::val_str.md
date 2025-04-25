#1.Field::val_str

```
Field::val_str
--Field_varstring::val_str
----uint length=  length_bytes == 1 ? (uint) *ptr : uint2korr(ptr);
----val_ptr->set((const char*) ptr+length_bytes, length, field_charset);
 ----return val_ptr;

```