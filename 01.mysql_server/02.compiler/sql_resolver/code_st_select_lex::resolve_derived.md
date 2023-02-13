#1.st_select_lex::resolve_derived

```
st_select_lex::resolve_derived
--for (TABLE_LIST *tl= get_table_list(); tl; tl= tl->next_local)
----if (!tl->is_view_or_derived() || tl->is_merged())
------continue;
----if (tl->resolve_derived(thd, apply_semijoin))
------DBUG_RETURN(true);
--if (!(thd->lex->context_analysis_only & CONTEXT_ANALYSIS_ONLY_VIEW) &&
      first_execution)
----for (TABLE_LIST *tl= get_table_list(); tl; tl= tl->next_local)
------if (!tl->is_view_or_derived() ||
          tl->is_merged() ||
          !tl->is_mergeable())
--------continue;
------if (merge_derived(thd, tl))
--------DBUG_RETURN(true);        /* purecov: inspected */
--for (TABLE_LIST *tl= get_table_list(); tl; tl= tl->next_local)
----if (tl->setup_materialized_derived(thd))
      DBUG_RETURN(true);
```