#1.SELECT_LEX::setup_conds

```
SELECT_LEX::setup_conds
--/*
    Apply fix_fields() to all ON clauses at all levels of nesting,
    including the ones inside view definitions.
  */
--for (TABLE_LIST *table= leaf_tables; table; table= table->next_leaf)
----

```