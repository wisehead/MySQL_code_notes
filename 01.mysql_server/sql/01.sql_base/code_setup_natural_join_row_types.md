#1.setup_natural_join_row_types

```
setup_natural_join_row_types
--for (left_neighbor= table_ref_it++; left_neighbor ; )
----if (left_neighbor && context->select_lex->first_execution)
------left_neighbor->next_name_resolution_table=table_ref->first_leaf_for_name_resolution();
--------TABLE_LIST::first_leaf_for_name_resolution
----right_neighbor= table_ref;
--context->first_name_resolution_table=
    right_neighbor->first_leaf_for_name_resolution();
```

#2.TABLE_LIST::first_leaf_for_name_resolution

```
TABLE_LIST::first_leaf_for_name_resolution
--TABLE_LIST::is_leaf_for_name_resolution
----
```