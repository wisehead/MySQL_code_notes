#1.class Key_spec

```cpp

class Key_spec {
 public:
  const keytype type;
  const KEY_CREATE_INFO key_create_info;
  Mem_root_array<Key_part_spec *> columns;
  LEX_CSTRING name;
  const bool generated;
  /**
    A flag to determine if we will check for duplicate indexes.
    This typically means that the key information was specified
    directly by the user (set by the parser) or a column
    associated with it was dropped.
  */
  const bool check_for_duplicate_indexes;

  Key_spec(MEM_ROOT *mem_root, keytype type_par, const LEX_CSTRING &name_arg,
           const KEY_CREATE_INFO *key_info_arg, bool generated_arg,
           bool check_for_duplicate_indexes_arg, List<Key_part_spec> &cols)
      : type(type_par),
        key_create_info(*key_info_arg),
        columns(mem_root),
        name(name_arg),
        generated(generated_arg),
        check_for_duplicate_indexes(check_for_duplicate_indexes_arg) {
    columns.reserve(cols.elements);
    List_iterator<Key_part_spec> it(cols);
    Key_part_spec *column;
    while ((column = it++)) columns.push_back(column);
  }

  virtual ~Key_spec() {}
};
```