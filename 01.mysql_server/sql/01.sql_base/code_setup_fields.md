#1.setup_fields

```
setup_fields
--if (want_privilege & SELECT_ACL)
    thd->mark_used_columns= MARK_COLUMNS_READ;
--if (allow_sum_func)
    thd->lex->allow_sum_func|= (nesting_map)1 << select->nest_level;
--thd->where= THD::DEFAULT_WHERE;
--List_iterator<Item_func_set_user_var> li(thd->lex->set_var_list);
--Item_func_set_user_var *var;
--while ((var= li++))
----var->set_entry(thd, FALSE);
--while ((item= it++))
----((!item->fixed && item->fix_fields(thd, it.ref())) ||
	(item= *(it.ref()))->check_cols(1))
----if (!ref.is_null())
------ref[0]= item;
------ref.pop_front();
----select->select_list_tables|= item->used_tables();
----thd->lex->used_tables|= item->used_tables();
```