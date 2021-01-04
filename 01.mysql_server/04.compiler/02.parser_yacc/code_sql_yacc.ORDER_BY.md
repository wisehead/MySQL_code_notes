#1.select order by

```cpp
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

