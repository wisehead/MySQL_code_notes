#1.SELECT_LEX::prepare

```
SELECT_LEX::prepare
--SELECT_LEX_UNIT *const unit= master_unit();
--if (top_join_list.elements > 0)
----propagate_nullability(&top_join_list, false);
--allow_merge_derived=
    outer_select() == NULL ||
    master_unit()->item == NULL ||
    (outer_select()->outer_select() == NULL ?
      parent_lex->sql_command == SQLCOM_SELECT :
      outer_select()->allow_merge_derived);
--if (!(active_options() & OPTION_SETUP_TABLES_DONE))
----setup_tables(thd, get_table_list(), false)
----if (derived_table_count && resolve_derived(thd, true))
------DBUG_RETURN(true);
----if (!thd->derived_tables_processing &&
        check_view_privileges(thd, SELECT_ACL, SELECT_ACL))
      DBUG_RETURN(true); 
--if (with_wild && setup_wild(thd))
----DBUG_RETURN(true);
--setup_ref_array(thd)
--setup_fields(thd, ref_ptrs, fields_list, thd->want_privilege,
                   &all_fields, true, false)
--thd->mark_used_columns= MARK_COLUMNS_READ;
--thd->want_privilege= SELECT_ACL;
--setup_conds
--if (group_list.elements && setup_group(thd))
    DBUG_RETURN(true);
--flatten_subqueries
--apply_local_transforms
```