#1.st_select_lex_unit::optimize

```
st_select_lex_unit::optimize
--for (SELECT_LEX *sl= first_select(); sl; sl= sl->next_select())
----thd->lex->set_current_select(sl);
----set_limit(sl);
----sl->optimize(thd)
```