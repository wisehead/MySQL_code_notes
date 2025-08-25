#1.Optimize_table_order::find_best_ref

```cpp
Optimize_table_order::find_best_ref
--enum idx_type {CLUSTERED_PK, UNIQUE, NOT_UNIQUE, FULLTEXT};
--ha_rows distinct_keys_est= tab->records()/MATCHING_ROWS_IN_OTHER_TABLE;
--for (Key_use *keyuse= tab->keyuse(); keyuse->table_ref == tab->table_ref; )
----// For each keypart
----while (keyuse->table_ref == tab->table_ref && keyuse->key == key)
------for ( ;
           keyuse->table_ref == tab->table_ref &&
           keyuse->key == key &&
           keyuse->keypart == keypart;
           ++keyuse)
--------/*
          This keyuse cannot be used if 
          1) it is a key reference between a table inside a semijoin
             nest and one outside of it. The same applices to
             materialized subqueries
          2) it is a key reference to a table that is not in the plan
             prefix (i.e., a table that will be later in the join
             sequence)
          3) there will be two ref_or_null keyparts 
             ("WHERE col=... OR col IS NULL"). Thus if
             a) the condition for an earlier keypart is of type
                ref_or_null, and
             b) the condition for the current keypart is ref_or_null
        */
--------if ((excluded_tables & keyuse->used_tables) ||        // 1)
            (remaining_tables & keyuse->used_tables) ||       // 2)
            (ref_or_null_part &&                              // 3a)
             (keyuse->optimize & KEY_OPTIMIZE_REF_OR_NULL)))  // 3b)
          continue;
--------const double cur_distinct_prefix_rowcount=
          prev_record_reads(join, idx, (table_deps | keyuse->used_tables));
```

#2.caller

```
JOIN::make_join_plan
--Optimize_table_order::choose_table_order
----Optimize_table_order::greedy_search
------Optimize_table_order::best_extension_by_limited_search
--------ptimize_table_order::best_access_path
----------find_best_ref
------

```