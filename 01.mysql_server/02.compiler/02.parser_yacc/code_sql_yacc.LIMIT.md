#1.LIMIT

```cpp
limit_clause:
          LIMIT limit_options
          {
            Lex->set_stmt_unsafe(LEX::BINLOG_STMT_UNSAFE_LIMIT);
          }
        ;
delete_limit_clause:
          /* empty */
          {
            LEX *lex=Lex;
            lex->current_select->select_limit= 0;
          }
        | LIMIT limit_option
          {
            SELECT_LEX *sel= Select;
            sel->select_limit= $2;
            Lex->set_stmt_unsafe(LEX::BINLOG_STMT_UNSAFE_LIMIT);
            sel->explicit_limit= 1;
          }
        ;
                
```


#2 limit_clause

```cpp
opt_limit_clause_init:
          /* empty */
          {
            LEX *lex= Lex;
            SELECT_LEX *sel= lex->current_select;
            sel->offset_limit= 0;
            sel->select_limit= 0;
          }
        | limit_clause {}
        ;

opt_limit_clause:
          /* empty */ {}
        | limit_clause {}
        ;
        
order_or_limit:
          order_clause opt_limit_clause_init
        | limit_clause
        ;        
```

#3.opt_limit_clause_init
```cpp
show_param:
        | BINLOG_SYM EVENTS_SYM binlog_in binlog_from
          {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_SHOW_BINLOG_EVENTS;
          } opt_limit_clause_init
        | RELAYLOG_SYM EVENTS_SYM binlog_in binlog_from
          {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_SHOW_RELAYLOG_EVENTS;
          } opt_limit_clause_init

order_or_limit:
          order_clause opt_limit_clause_init
        | limit_clause
        ;

```

#4. show_param

```cpp
/* Show things */

show://command
          SHOW
          {
            LEX *lex=Lex;
            lex->wild=0;
            mysql_init_select(lex);
            lex->current_select->parsing_place= SELECT_LIST;
            memset(&lex->create_info, 0, sizeof(lex->create_info));
          }
          show_param
          {
            Select->parsing_place= NO_MATTER;
          }
        ;
```

#5.opt_limit_clause
```cpp
opt_select_from:
          opt_limit_clause {}
        | select_from select_lock_type
        ;
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
** Handler: direct access to ISAM functions
*/

handler://statement
          handler_read_or_scan where_clause opt_limit_clause        
```


#6.order_or_limit
```cpp
union_order_or_limit:
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            DBUG_ASSERT(lex->current_select->linkage != GLOBAL_OPTIONS_TYPE);
            SELECT_LEX *sel= lex->current_select;
            SELECT_LEX_UNIT *unit= sel->master_unit();
            SELECT_LEX *fake= unit->fake_select_lex;
            if (fake)
            {
              unit->global_parameters= fake;
              fake->no_table_names_allowed= 1;
              lex->current_select= fake;
            }
            thd->where= "global ORDER clause";
          }
          order_or_limit
          {
            THD *thd= YYTHD;
            thd->lex->current_select->no_table_names_allowed= 0;
            thd->where= "";
          }
        ;


```

#7. union_order_or_limit
```cpp
union_opt:
          /* Empty */ { $$= 0; }
        | union_list { $$= 1; }
        | union_order_or_limit { $$= 1; }
        ;

opt_union_order_or_limit:
      /* Empty */ { $$= false; }
    | union_order_or_limit { $$= true; }
    ;

```

#8. union_opt

```cpp

```


# delete_limit_clause
opt_limit_clause
