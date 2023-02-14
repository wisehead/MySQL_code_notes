#1.Query::Compile

```
Query::Compile
--for (SELECT_LEX *sl = selects_list; sl; sl = sl->next_select()) 
----SetLimit(sl, sl == selects_list ? 0 : sl->join->unit->global_parameters(), offset_value, limit_value);
----Item *conds = (ifNewJoinForTianmu || !sl->join->where_cond) ? sl->where_cond() : sl->join->where_cond;
----AddJoins
```