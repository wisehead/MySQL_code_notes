#1.class DescTree

```cpp
// Tree of descriptors: internal nodes - predicates, leaves - terms
// Used to store conditions filtering output columns of TempTable
// Used, particularly, to store conditions of 'having' clause

class DescTree {
 public:
  DescTreeNode *root, *curr;
...
...  
};  
```