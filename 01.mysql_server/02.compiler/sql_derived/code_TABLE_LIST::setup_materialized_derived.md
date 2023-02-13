#1.TABLE_LIST::setup_materialized_derived

```
TABLE_LIST::setup_materialized_derived
--set_uses_materialization
----effective_algorithm= VIEW_ALGORITHM_TEMPTABLE;
--const ulonglong create_options= derived->first_select()->active_options() |
                                  TMP_TABLE_ALL_COLUMNS;
--(derived_result->create_result_table(thd, &derived->types, false, 
                                          create_options,
                                          alias, false, false))
--table= derived_result->table;
--table->pos_in_table_list= this;
--set_name_temporary
--table->s->tmp_table= NON_TRANSACTIONAL_TMP_TABLE;
--if (is_inner_table_of_outer_join())
----table->set_nullable();
--table->next= thd->derived_tables;
--thd->derived_tables= table;
--for (SELECT_LEX *sl= derived->first_select(); sl; sl= sl->next_select())
----sl->check_view_privileges(thd, SELECT_ACL, SELECT_ACL)
----while ((item= it++))
------if (item->walk(&Item::check_column_privileges, Item::WALK_PREFIX,
                     (uchar *)thd))
--------DBUG_RETURN(true);
------item->walk(&Item::mark_field_in_map, Item::WALK_POSTFIX, (uchar *)&mf);
```