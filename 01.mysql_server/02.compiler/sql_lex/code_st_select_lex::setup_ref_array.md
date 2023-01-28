#1.st_select_lex::setup_ref_array

```
st_select_lex::setup_ref_array
--/*
    We have to create array in prepared statement memory if it is
    prepared statement
  */
--Query_arena *arena= thd->stmt_arena;
--const uint n_elems= (n_sum_items +
                       n_child_sum_items +
                       item_list.elements +
                       select_n_having_items +
                       select_n_where_fields +
                       order_group_num) * 5;
--Item **array= static_cast<Item**>(arena->alloc(sizeof(Item*) * n_elems));
--if (array != NULL)
----ref_pointer_array= Ref_ptr_array(array, n_elems);
----ref_ptrs= ref_ptr_array_slice(0);
```