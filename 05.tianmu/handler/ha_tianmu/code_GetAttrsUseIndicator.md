#1.GetAttrsUseIndicator

```
GetAttrsUseIndicator
--if (table->in_use && table->in_use->lex)
    sql_command = table->in_use->lex->sql_command;
--for (Field **field = table->field; *field; ++field, ++col_id)
----if (check_tianmu_delete_or_update) {
------attr_uses.push_back(true);
------continue;
--return attr_uses;
```