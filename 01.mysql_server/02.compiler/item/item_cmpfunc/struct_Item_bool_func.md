#1.struct Item_bool_func

```cpp
class Item_bool_func :public Item_int_func
{
public:
  Item_bool_func() : Item_int_func(), m_created_by_in2exists(false) {}
  explicit Item_bool_func(const POS &pos)
  : Item_int_func(pos), m_created_by_in2exists(false)
  {}

  Item_bool_func(Item *a) : Item_int_func(a),
    m_created_by_in2exists(false)  {}
  Item_bool_func(const POS &pos, Item *a) : Item_int_func(pos, a),
    m_created_by_in2exists(false)  {}

  Item_bool_func(Item *a,Item *b) : Item_int_func(a,b),
    m_created_by_in2exists(false)  {}
  Item_bool_func(const POS &pos, Item *a,Item *b) : Item_int_func(pos, a,b),
    m_created_by_in2exists(false)  {}

  Item_bool_func(THD *thd, Item_bool_func *item) : Item_int_func(thd, item),
    m_created_by_in2exists(item->m_created_by_in2exists) {}
  bool is_bool_func() { return 1; }
  void fix_length_and_dec() { decimals=0; max_length=1; }
  uint decimal_precision() const { return 1; }
  virtual bool created_by_in2exists() const { return m_created_by_in2exists; }
  void set_created_by_in2exists() { m_created_by_in2exists= true; }
private:
  /**
    True <=> this item was added by IN->EXISTS subquery transformation, and
    should thus be deleted if we switch to materialization.
  */
  bool m_created_by_in2exists;
};

```