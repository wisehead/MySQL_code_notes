#1.st_select_lex_unit::prepare

```
st_select_lex_unit::prepare
--SELECT_LEX *last_select= first_select();
--while (last_select->next_select())
----last_select= last_select->next_select();
--set_query_result(sel_result);
--thd_arg->lex->set_current_select(first_select());
--found_rows_for_union= first_select()->active_options() & OPTION_FOUND_ROWS;
--const bool simple_query_expression= is_simple();
--if (!simple_query_expression)
--else
----tmp_result= sel_result;
--for (SELECT_LEX *sl= first_select(); sl; sl= sl->next_select())
----sl->set_query_result(tmp_result);
----sl->make_active_options(added_options | SELECT_NO_UNLOCK, removed_options);
----sl->fields_list= sl->item_list;
----added_options&= ~OPTION_SETUP_TABLES_DONE;
----thd_arg->lex->set_current_select(sl);
----if (sl->prepare(thd_arg))
      goto err;
----if (simple_query_expression)
------types= first_select()->item_list;
--//end for
--thd_arg->lex->set_current_select(lex_select_save);
--set_prepared
```