#1.class Key_part_spec

```cpp
class Key_part_spec :public Sql_alloc {
public:
  LEX_STRING field_name;
  uint length;
  Key_part_spec(const LEX_STRING &name, uint len)
    : field_name(name), length(len)
  {}
  Key_part_spec(const char *name, const size_t name_len, uint len)
    : length(len)
  { field_name.str= (char *)name; field_name.length= name_len; }
  bool operator==(const Key_part_spec& other) const;
  /**
    Construct a copy of this Key_part_spec. field_name is copied
    by-pointer as it is known to never change. At the same time
    'length' may be reset in mysql_prepare_create_table, and this
    is why we supply it with a copy.

    @return If out of memory, 0 is returned and an error is set in
    THD.
  */
  Key_part_spec *clone(MEM_ROOT *mem_root) const
  { return new (mem_root) Key_part_spec(*this); }
};
```