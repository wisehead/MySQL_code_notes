#1.MysqlExpression::Evaluate

```
MysqlExpression::Evaluate
--switch (mysql_type)
----case STRING_RESULT:
------return ItemString2ValueOrNull(item, type.precision, type.attrtype);
```