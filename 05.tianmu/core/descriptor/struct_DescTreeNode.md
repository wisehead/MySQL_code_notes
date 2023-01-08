#1.struct DescTreeNode

```cpp
struct DescTreeNode {
  int locks_size = 0;
  std::vector<int> locks;  // for a leaf: >= 0 => source pack must be locked
                           // before use, -1 => already locked

  Descriptor desc;
  int locked;  // for a leaf: >= 0 => source pack must be locked before use, -1
               // => already locked
  DescTreeNode *left, *right, *parent;
};
```