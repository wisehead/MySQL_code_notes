#1.struct ib_rbt_t

```cpp
/** Red black tree instance.*/
struct ib_rbt_t {
  ib_rbt_node_t *nil; /* Black colored node that is
                      used as a sentinel. This is
                      pre-allocated too.*/

  ib_rbt_node_t *root; /* Root of the tree, this is
                       pre-allocated and the first
                       data node is the left child.*/

  ulint n_nodes; /* Total number of data nodes */

  ib_rbt_compare compare;              /* Fn. to use for comparison */
  ib_rbt_arg_compare compare_with_arg; /* Fn. to use for comparison
                                       with argument */
  ulint sizeof_value;                  /* Sizeof the item in bytes */
  void *cmp_arg;                       /* Compare func argument */
};
```