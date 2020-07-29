#1.struct ib_rbt_node_t


```cpp
/** Red black tree node */
struct ib_rbt_node_t {
  ib_rbt_color_t color; /* color of this node */

  ib_rbt_node_t *left;   /* points left child */
  ib_rbt_node_t *right;  /* points right child */
  ib_rbt_node_t *parent; /* points parent node */

  char value[1]; /* Data value */
};
```