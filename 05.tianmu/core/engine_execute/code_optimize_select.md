#1. optimize_select

```
/*
Prepares and optimizes a single select for Tianmu engine
*/
optimize_select
--if (select_lex->join != 0) {
--else
----err = select_lex->prepare(thd)
------SELECT_LEX::prepare
----join = new JOIN(thd, select_lex)
----select_lex->set_join(join);
------join= join_arg;
--join->optimize(1)
```

#2.caller

```
Engine::HandleSelect
```