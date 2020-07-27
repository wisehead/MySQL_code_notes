#1.class dd::Index

```cpp
class Index : virtual public Entity_object {
 public:
  typedef Collection<Index_element *> Index_elements;
  typedef Index_impl Impl;
  typedef tables::Indexes DD_table;

 public:
  enum enum_index_type  // similar to Keytype in sql_class.h but w/o FOREIGN_KEY
  { IT_PRIMARY = 1,
    IT_UNIQUE,
    IT_MULTIPLE,
    IT_FULLTEXT,
    IT_SPATIAL };

  enum enum_index_algorithm  // similar to ha_key_alg
  { IA_SE_SPECIFIC = 1,
    IA_BTREE,
    IA_RTREE,
    IA_HASH,
    IA_FULLTEXT };
};    
```
