#1.select order by

```cpp
select_into:
          opt_order_clause opt_limit_clause {}
        | into
        | select_from
        | into select_from
        | select_from into
        ;

select_from:
          FROM join_table_list where_clause group_clause having_clause
          opt_order_clause opt_limit_clause procedure_analyse_clause
          {
            Select->context.table_list=
              Select->context.first_name_resolution_table=
                Select->table_list.first;
          }
        | FROM DUAL_SYM where_clause opt_limit_clause
          /* oracle compatibility: oracle always requires FROM clause,
             and DUAL is system table without fields.
             Is "SELECT 1 FROM DUAL" any better than "SELECT 1" ?
          Hmmm :) */
        ;
        

/*
   Order by statement in select
*/

opt_order_clause:
          /* empty */
        | order_clause
        ;

order_clause:
          ORDER_SYM BY
          {
            LEX *lex=Lex;
            SELECT_LEX *sel= lex->current_select;
            SELECT_LEX_UNIT *unit= sel-> master_unit();
            if (sel->linkage != GLOBAL_OPTIONS_TYPE &&
                sel->olap != UNSPECIFIED_OLAP_TYPE &&
                (sel->linkage != UNION_TYPE || sel->braces))
            {
              my_error(ER_WRONG_USAGE, MYF(0),
                       "CUBE/ROLLUP", "ORDER BY");
              MYSQL_YYABORT;
            }
            if (lex->sql_command != SQLCOM_ALTER_TABLE && !unit->fake_select_lex)
            {
              /*
                A query of the of the form (SELECT ...) ORDER BY order_list is
                executed in the same way as the query
                SELECT ... ORDER BY order_list
                unless the SELECT construct contains ORDER BY or LIMIT clauses.
                Otherwise we create a fake SELECT_LEX if it has not been created
                yet.
              */
              SELECT_LEX *first_sl= unit->first_select();
              if (!unit->is_union() &&
                  (first_sl->order_list.elements ||
                   first_sl->select_limit) &&
                  unit->add_fake_select_lex(lex->thd))
                MYSQL_YYABORT;
            }
          }
          order_list
        ;

order_list:
          order_list ',' order_ident order_dir
          { if (add_order_to_list(YYTHD, $3,(bool) $4)) MYSQL_YYABORT; }
        | order_ident order_dir
          { if (add_order_to_list(YYTHD, $1,(bool) $2)) MYSQL_YYABORT; }
        ;

order_dir:
          /* empty */ { $$ =  1; }
        | ASC  { $$ =1; }
        | DESC { $$ =0; }
        ;
        
```

#2.update order by

```cpp
/* Update rows in a table */

update:
          UPDATE_SYM
          {
            LEX *lex= Lex;
            mysql_init_select(lex);
            lex->sql_command= SQLCOM_UPDATE;
            lex->duplicates= DUP_ERROR;
          }
          opt_low_priority opt_ignore join_table_list
          SET update_list
          {
            LEX *lex= Lex;
            if (lex->select_lex.table_list.elements > 1)
              lex->sql_command= SQLCOM_UPDATE_MULTI;
            else if (lex->select_lex.get_table_list()->derived)
            {
              /* it is single table update and it is update of derived table */
              my_error(ER_NON_UPDATABLE_TABLE, MYF(0),
                       lex->select_lex.get_table_list()->alias, "UPDATE");
              MYSQL_YYABORT;
            }
            /*
              In case of multi-update setting write lock for all tables may
              be too pessimistic. We will decrease lock level if possible in
              mysql_multi_update().
            */
            Select->set_lock_for_tables($3);
          }
          where_clause opt_order_clause delete_limit_clause {}
        ;
```

#3.delete

```cpp
/* Delete rows from a table */

delete:
          DELETE_SYM
          {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_DELETE;
            mysql_init_select(lex);
            YYPS->m_lock_type= TL_WRITE_DEFAULT;
            YYPS->m_mdl_type= MDL_SHARED_WRITE;

            lex->ignore= 0;
            lex->select_lex.init_order();
          }
          opt_delete_options single_multi
        ;

single_multi:
          FROM table_ident opt_use_partition
          {
            if (!Select->add_table_to_list(YYTHD, $2, NULL, TL_OPTION_UPDATING,
                                           YYPS->m_lock_type,
                                           YYPS->m_mdl_type,
                                           NULL,
                                           $3))
              MYSQL_YYABORT;
            YYPS->m_lock_type= TL_READ_DEFAULT;
            YYPS->m_mdl_type= MDL_SHARED_READ;
          }
          where_clause opt_order_clause
          delete_limit_clause {}
        | table_wild_list
          {
            mysql_init_multi_delete(Lex);
            YYPS->m_lock_type= TL_READ_DEFAULT;
            YYPS->m_mdl_type= MDL_SHARED_READ;
          }
          FROM join_table_list where_clause
          {
            if (multi_delete_set_locks_and_link_aux_tables(Lex))
              MYSQL_YYABORT;
          }
        | FROM table_alias_ref_list
          {
            mysql_init_multi_delete(Lex);
            YYPS->m_lock_type= TL_READ_DEFAULT;
            YYPS->m_mdl_type= MDL_SHARED_READ;
          }
          USING join_table_list where_clause
          {
            if (multi_delete_set_locks_and_link_aux_tables(Lex))
              MYSQL_YYABORT;
          }
        ;
```

#4. select_into

```cpp
        
select_part2:
          {
            LEX *lex= Lex;
            SELECT_LEX *sel= lex->current_select;
            if (sel->linkage != UNION_TYPE)
              mysql_init_select(lex);
            lex->current_select->parsing_place= SELECT_LIST;
          }
          select_options select_item_list
          {
            Select->parsing_place= NO_MATTER;
          }
          select_into select_lock_type
        ;
        
        
```

#5. select_part2

```cpp
select_paren:
          SELECT_SYM select_part2
          {
            if (setup_select_in_parentheses(Lex))
              MYSQL_YYABORT;
          }
        | '(' select_paren ')'
        ;
        
select_init2:
          select_part2
          {
            LEX *lex= Lex;
            SELECT_LEX * sel= lex->current_select;
            if (lex->current_select->set_braces(0))
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
            if (sel->linkage == UNION_TYPE &&
                sel->master_unit()->first_select()->braces)
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
          }
          union_clause
        ;
        
create_view_select:
          SELECT_SYM
          {
            Lex->current_select->table_list.save_and_clear(&Lex->save_list);
          }
          select_part2
          {
            Lex->current_select->table_list.push_front(&Lex->save_list);
          }
        ;
                
```

#6.select_paren

```cpp
```

#select_init2
#create_view_select
#. select_from