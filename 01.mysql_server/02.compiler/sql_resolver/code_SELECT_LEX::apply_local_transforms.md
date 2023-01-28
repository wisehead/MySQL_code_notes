#1.SELECT_LEX::apply_local_transforms
```
SELECT_LEX::apply_local_transforms
--if (first_execution &&
      !(thd->lex->context_analysis_only & CONTEXT_ANALYSIS_ONLY_VIEW))
----if (simplify_joins(thd, &top_join_list, true, false, &m_where_cond))
      DBUG_RETURN(true);
----if (record_join_nest_info(&top_join_list))
      DBUG_RETURN(true);
----build_bitmap_for_nested_joins      
```