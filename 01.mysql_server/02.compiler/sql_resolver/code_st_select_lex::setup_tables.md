#1.st_select_lex::setup_tables

```
st_select_lex::setup_tables
--make_leaf_tables(&leaf_tables, tables);
----for (TABLE_LIST *table= tables; table; table= table->next_local)
------if (table->merge_underlying_list)
------else
--------*list= table;
--------list= &table->next_leaf;
--if (select_insert)
----//
--for (TABLE_LIST *tr= leaf_tables; tr; tr= tr->next_leaf, tableno++)
----tr->set_tableno(tableno);
----table->pos_in_table_list= tr;
----tr->reset();
----tr->process_index_hints(table)
```