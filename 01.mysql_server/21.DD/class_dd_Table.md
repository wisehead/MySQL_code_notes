#1.class dd:Table

```cpp
class Table : virtual public Abstract_table {
 public:
  typedef Table_impl Impl;
  typedef Collection<Index *> Index_collection;
  typedef Collection<Foreign_key *> Foreign_key_collection;
  typedef std::vector<Foreign_key_parent *> Foreign_key_parent_collection;
  typedef Collection<Partition *> Partition_collection;
  typedef Collection<Trigger *> Trigger_collection;
  typedef Collection<Check_constraint *> Check_constraint_collection;

  /*
    The type Partition_collection object 'own' the Partition* object. That
    means that the object Partition* would be deleted when the
    Partition_collection is deleted. However the Partition_leaf_vector type
    does not 'own' the Partition* object and points to one of element
    owned by Partition_collection. Deleting Partition_leaf_vector will not
    delete the Partition* objects pointed by it.
  */
  typedef std::vector<Partition *> Partition_leaf_vector;
};  
```