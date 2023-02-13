#1.st_select_lex::resolve_derived

```
st_select_lex::resolve_derived
--for (TABLE_LIST *tl= get_table_list(); tl; tl= tl->next_local)
----if (!tl->is_view_or_derived() || tl->is_merged())
------continue;
----if (tl->resolve_derived(thd, apply_semijoin))
------DBUG_RETURN(true);
```