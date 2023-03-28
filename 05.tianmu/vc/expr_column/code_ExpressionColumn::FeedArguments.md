#1.ExpressionColumn::FeedArguments

```
ExpressionColumn::FeedArguments
--bool diff = first_eval_;
--for (auto &it : var_map_) {
----core::ValueOrNull v(it.just_a_table_ptr->GetComplexValue(mit[it.dim], it.col_ndx));
----ValueOrNull::MakeStringOwner
----auto cache = var_buf_.find(it.var_id);
----diff = diff || (v != cache->second.begin()->first);
----if (diff)
------for (auto &val_it : cache->second) *(val_it.second) = val_it.first = v;
--first_eval_ = false;
```