#1.class ParameterizedFilter

```cpp
/*
A class defining multidimensional filter (by means of MultiIndex) on a set of
tables. It can store descriptors defining some restrictions on particular
dimensions. It can be parametrized thus the multiindex is not materialized. It
can also store tree of conditions
*/

class ParameterizedFilter final {
 public:
  // for copy ctor. shallow cpy
  bool mind_shallow_memory_;

  MultiIndex *mind_;
  RoughMultiIndex *rough_mind_;
  TempTable *table_;

 private:
  Condition descriptors_;
  Condition parametrized_desc_;
  CondType filter_type_;
};
```