#1.struct Query_cache_block_table

```cpp
/**
  This class represents a node in the linked chain of queries
  belonging to one table.

  @note The root of this linked list is not a query-type block, but the table-
        type block which all queries has in common.
*/
struct Query_cache_block_table
{
  Query_cache_block_table() {}                /* Remove gcc warning */

  /**
    This node holds a position in a static table list belonging
    to the associated query (base 0).
  */
  TABLE_COUNTER_TYPE n;

  /**
    Pointers to the next and previous node, linking all queries with
    a common table.
  */
  Query_cache_block_table *next, *prev;

  /**
    A pointer to the table-type block which all
    linked queries has in common.
  */
  Query_cache_table *parent;

  /**
    A method to calculate the address of the query cache block
    owning this node. The purpose of this calculation is to
    make it easier to move the query cache block without having
    to modify all the pointer addresses.
  */
  inline Query_cache_block *block();
};

```