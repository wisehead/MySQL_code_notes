#1.optimize_fts_limit_query

```cpp
/*
对全文检索的查询语句进行优化。支持的格式如下：

要用optimize_fts_limit_query函数进行优化，必须满足以下条件：

❏查询语句必须是单表查询（FROM-LIST，只一个表Table_obj）。❏没有WHERE子句。

❏只有一个单一的ORDERBY子句（如col_objX）。

❏ORDERBY子句按降序排列。❏有一个LIMIT子句。\

❏使用了全文检索函数（函数类型为FT_FUNC）。

由于optimize_fts_limit_query不是查询优化技术的重点内容，不再赘述。
*/
```