#1.class Key

```cpp
class Key :public Sql_alloc {
public:
  enum Keytype { PRIMARY, UNIQUE, MULTIPLE, FULLTEXT, SPATIAL, FOREIGN_KEY};
  enum Keytype type;
  KEY_CREATE_INFO key_create_info;
  List<Key_part_spec> columns;
  LEX_STRING name;
  bool generated;
};
```