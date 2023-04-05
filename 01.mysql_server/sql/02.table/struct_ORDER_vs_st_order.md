#1. ORDER(st_order)

```cpp
typedef struct st_order {
  struct st_order *next;
  Item   **item;                        /* Point at item in select fields */
  Item   *item_ptr;                     /* Storage for initial item */
  int    counter;                       /* position in SELECT list, correct
                                           only if counter_used is true */
  enum enum_order {
    ORDER_NOT_RELEVANT,
    ORDER_ASC,
    ORDER_DESC
  };

  enum_order direction;                 /* Requested direction of ordering */
  bool   in_field_list;                 /* true if in select field list */
  bool   counter_used;                  /* parameter was counter of columns */
  /**
     Tells whether this ORDER element was referenced with an alias or with an
     expression, in the query:
     SELECT a AS foo GROUP BY foo: true.
     SELECT a AS foo GROUP BY a: false.
  */
  bool   used_alias;
  Field  *field;                        /* If tmp-table group */
  char   *buff;                         /* If tmp-table group */
  table_map used, depend_map;
} ORDER;
```