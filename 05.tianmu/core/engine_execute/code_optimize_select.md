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
```

#2.caller

```
Engine::HandleSelect
```