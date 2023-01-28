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
/* Need select_init2 for subselects. */
select_init:
          SELECT_SYM select_init2
        | '(' select_paren ')' union_opt
        ;
```

#7.select_init

```cpp
/*
  Select : retrieve data from table
*/


select:
          select_init
          {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_SELECT;
          }
        ;
union_list:
          UNION_SYM union_option
          {
            if (add_select_to_union_list(Lex, (bool)$2, TRUE))
              MYSQL_YYABORT;
          }
          select_init
          {
            /*
              Remove from the name resolution context stack the context of the
              last select in the union.
            */
            Lex->pop_context();
          }
        ;        
```

#8.select

```cpp
/* Verb clauses, except begin */
statement:
          activate_risky_command
        | alter
        | analyze
        | binlog_base64_event
        | call
        | change
        | check
        | checksum
        | commit
        | create
        | deactivate_risky_command
        | deallocate
        | delete
        | describe
        | do
        | drop
        | execute
        | flush
        | get_diagnostics
        | grant
        | handler
        | help
        | insert
        | install
        | kill
        | load
        | lock
        | optimize
        | keycache
        | partition_entry
        | preload
        | prepare
        | purge
        | release
        | rename
        | repair
        | replace
        | reset
        | resignal_stmt
        | revoke
        | rollback
        | savepoint
        | select
        | set
        | signal_stmt
        | show
        | slave
        | start
        | truncate
        | uninstall
        | unlock
        | update
        | use
        | xa
        ;
```

#9.select_init2

```cpp
/* Need select_init2 for subselects. */
select_init:
          SELECT_SYM select_init2
        | '(' select_paren ')' union_opt
        ;
```

#10.create_view_select
#11. select_from
```cpp
opt_select_from:
          opt_limit_clause {}
        | select_from select_lock_type
        ;

/*
 End of partition parser part
*/
```

#12. opt_select_from

```cpp

create_select:
          SELECT_SYM
          {
            LEX *lex=Lex;
            if (lex->sql_command == SQLCOM_INSERT)
              lex->sql_command= SQLCOM_INSERT_SELECT;
            else if (lex->sql_command == SQLCOM_REPLACE)
              lex->sql_command= SQLCOM_REPLACE_SELECT;
            /*
              The following work only with the local list, the global list
              is created correctly in this case
            */
            lex->current_select->table_list.save_and_clear(&lex->save_list);
            mysql_init_select(lex);
            lex->current_select->parsing_place= SELECT_LIST;
          }
          select_options select_item_list
          {
            Select->parsing_place= NO_MATTER;
          }
          opt_select_from
          {
            /*
              The following work only with the local list, the global list
              is created correctly in this case
            */
            Lex->current_select->table_list.push_front(&Lex->save_list);
          }
        ;
        
/* The equivalent of select_part2 for nested queries. */
select_part2_derived:
          {
            LEX *lex= Lex;
            SELECT_LEX *sel= lex->current_select;
            if (sel->linkage != UNION_TYPE)
              mysql_init_select(lex);
            lex->current_select->parsing_place= SELECT_LIST;
          }
          opt_query_expression_options select_item_list
          {
            Select->parsing_place= NO_MATTER;
          }
          opt_select_from select_lock_type
        ;      

select_derived2:
          {
            LEX *lex= Lex;
            lex->derived_tables|= DERIVED_SUBQUERY;
            if (!lex->expr_allows_subselect ||
                lex->sql_command == (int)SQLCOM_PURGE)
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
            if (lex->current_select->linkage == GLOBAL_OPTIONS_TYPE ||
                mysql_new_select(lex, 1))
              MYSQL_YYABORT;
            mysql_init_select(lex);
            lex->current_select->linkage= DERIVED_TABLE_TYPE;
            lex->current_select->parsing_place= SELECT_LIST;
          }
          select_options select_item_list
          {
            Select->parsing_place= NO_MATTER;
          }
          opt_select_from
        ;
                          
```

#13. create_select
```cpp
create2a:
          create_field_list ')' opt_create_table_options
          opt_create_partitioning
          create3 {}
        |  opt_create_partitioning
           create_select ')'
           { Select->set_braces(1);}
           union_opt {}
        ;

create3:
          /* empty */ {}
        | opt_duplicate opt_as create_select
          { Select->set_braces(0);}
          union_clause {}
        | opt_duplicate opt_as '(' create_select ')'
          { Select->set_braces(1);}
          union_opt {}
        ;
insert_values:
          VALUES values_list {}
        | VALUE_SYM values_list {}
        | create_select
          { Select->set_braces(0);}
          union_clause {}
        | '(' create_select ')'
          { Select->set_braces(1);}
          union_opt {}
        ;        
```

#14.create2a
```cpp
create2:
          '(' create2a {}
        | opt_create_table_options
          opt_create_partitioning
          create3 {}
        | LIKE table_ident
          {
            THD *thd= YYTHD;
            TABLE_LIST *src_table;
            LEX *lex= thd->lex;

            lex->create_info.options|= HA_LEX_CREATE_TABLE_LIKE;
            src_table= lex->select_lex.add_table_to_list(thd, $2, NULL, 0,
                                                         TL_READ,
                                                         MDL_SHARED_READ);
            if (! src_table)
              MYSQL_YYABORT;
            /* CREATE TABLE ... LIKE is not allowed for views. */
            src_table->required_type= FRMTYPE_TABLE;
          }
        | '(' LIKE table_ident ')'
          {
            THD *thd= YYTHD;
            TABLE_LIST *src_table;
            LEX *lex= thd->lex;

            lex->create_info.options|= HA_LEX_CREATE_TABLE_LIKE;
            src_table= lex->select_lex.add_table_to_list(thd, $3, NULL, 0,
                                                         TL_READ,
                                                         MDL_SHARED_READ);
            if (! src_table)
              MYSQL_YYABORT;
            /* CREATE TABLE ... LIKE is not allowed for views. */
            src_table->required_type= FRMTYPE_TABLE;
          }
        ;
        
/* create a table */

create:
          CREATE opt_table_options TABLE_SYM opt_if_not_exists table_ident
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->sql_command= SQLCOM_CREATE_TABLE;
            if (!lex->select_lex.add_table_to_list(thd, $5, NULL,
                                                   TL_OPTION_UPDATING,
                                                   TL_WRITE, MDL_SHARED))
              MYSQL_YYABORT;
            /*
              Instruct open_table() to acquire SHARED lock to check the
              existance of table. If the table does not exist then
              it will be upgraded EXCLUSIVE MDL lock. If table exist
              then open_table() will return with an error or warning.
            */
            lex->query_tables->open_strategy= TABLE_LIST::OPEN_FOR_CREATE;
            lex->alter_info.reset();
            lex->col_list.empty();
            lex->change=NullS;
            memset(&lex->create_info, 0, sizeof(lex->create_info));
            lex->create_info.options=$2 | $4;
            lex->create_info.default_table_charset= NULL;
            lex->name.str= 0;
            lex->name.length= 0;
            lex->create_last_non_select_table= lex->last_table();
          }
          create2
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->current_select= &lex->select_lex;
            if ((lex->create_info.used_fields & HA_CREATE_USED_ENGINE) &&
                !lex->create_info.db_type)
            {
              lex->create_info.db_type=
                lex->create_info.options & HA_LEX_CREATE_TMP_TABLE ?
                ha_default_temp_handlerton(thd) : ha_default_handlerton(thd);
              push_warning_printf(YYTHD, Sql_condition::WARN_LEVEL_WARN,
                                  ER_WARN_USING_OTHER_HANDLER,
                                  ER(ER_WARN_USING_OTHER_HANDLER),
                                  ha_resolve_storage_engine_name(lex->create_info.db_type),
                                  $5->table.str);
            }
            create_table_set_open_action_and_adjust_tables(lex);
          }
        | CREATE opt_unique INDEX_SYM ident key_alg ON table_ident        
```

#15.create3

```cpp
create2:
          '(' create2a {}
        | opt_create_table_options
          opt_create_partitioning
          create3 {}
        | LIKE table_ident
          {
            THD *thd= YYTHD;
            TABLE_LIST *src_table;
            LEX *lex= thd->lex;

            lex->create_info.options|= HA_LEX_CREATE_TABLE_LIKE;
            src_table= lex->select_lex.add_table_to_list(thd, $2, NULL, 0,
                                                         TL_READ,
                                                         MDL_SHARED_READ);
            if (! src_table)
              MYSQL_YYABORT;
            /* CREATE TABLE ... LIKE is not allowed for views. */
            src_table->required_type= FRMTYPE_TABLE;
          }
        | '(' LIKE table_ident ')'
          {
            THD *thd= YYTHD;
            TABLE_LIST *src_table;
            LEX *lex= thd->lex;

            lex->create_info.options|= HA_LEX_CREATE_TABLE_LIKE;
            src_table= lex->select_lex.add_table_to_list(thd, $3, NULL, 0,
                                                         TL_READ,
                                                         MDL_SHARED_READ);
            if (! src_table)
              MYSQL_YYABORT;
            /* CREATE TABLE ... LIKE is not allowed for views. */
            src_table->required_type= FRMTYPE_TABLE;
          }
        ;

create2a:
          create_field_list ')' opt_create_table_options
          opt_create_partitioning
          create3 {}
        |  opt_create_partitioning
           create_select ')'
           { Select->set_braces(1);}
           union_opt {}
        ;
```

#16.insert_values
```cpp
insert_field_spec:
          insert_values {}
        | '(' ')' insert_values {}
        | '(' fields ')' insert_values {}
        | SET
          {
            LEX *lex=Lex;
            if (!(lex->insert_list = new List_item) ||
                lex->many_values.push_back(lex->insert_list))
              MYSQL_YYABORT;
          }
          ident_eq_list
        ;

/*
** Insert : add new data to table
*/

insert:
          INSERT
          {
            LEX *lex= Lex;
            lex->sql_command= SQLCOM_INSERT;
            lex->duplicates= DUP_ERROR;
            mysql_init_select(lex);
          }
          insert_lock_option
          opt_ignore insert2
          {
            Select->set_lock_for_tables($3);
            Lex->current_select= &Lex->select_lex;
          }
          insert_field_spec opt_insert_update
          {}
        ;

replace:
          REPLACE
          {
            LEX *lex=Lex;
            lex->sql_command = SQLCOM_REPLACE;
            lex->duplicates= DUP_REPLACE;
            mysql_init_select(lex);
          }
          replace_lock_option insert2
          {
            Select->set_lock_for_tables($3);
            Lex->current_select= &Lex->select_lex;
          }
          insert_field_spec
          {}
        ;        
```

#17.select_part2_derived

```cpp
/* The equivalent of select_paren for nested queries. */
select_paren_derived:
          SELECT_SYM select_part2_derived
          {
            if (setup_select_in_parentheses(Lex))
              MYSQL_YYABORT;
          }
        | '(' select_paren_derived ')'
        ;

/* The equivalent of select_init2 for nested queries. */
select_init2_derived:
          select_part2_derived
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
        ;        
```

#18.select_paren_derived
```cpp
query_specification:
          SELECT_SYM select_init2_derived
          {
            $$= Lex->current_select->master_unit()->first_select();
          }
        | '(' select_paren_derived ')'
          {
            $$= Lex->current_select->master_unit()->first_select();
          }
        ;
```

#19. query_specification

```cpp
/*
  This rule accepts just about anything. The reason is that we have
  empty-producing rules in the beginning of rules, in this case
  subselect_start. This forces bison to take a decision which rules to
  reduce by long before it has seen any tokens. This approach ties us
  to a very limited class of parseable languages, and unfortunately
  SQL is not one of them. The chosen 'solution' was this rule, which
  produces just about anything, even complete bogus statements, for
  instance ( table UNION SELECT 1 ).

  Fortunately, we know that the semantic value returned by
  select_derived is NULL if it contained a derived table, and a pointer to
  the base table's TABLE_LIST if it was a base table. So in the rule
  regarding union's, we throw a parse error manually and pretend it
  was bison that did it.

  Also worth noting is that this rule concerns query expressions in
  the from clause only. Top level select statements and other types of
  subqueries have their own union rules.
 */
select_derived_union:
          select_derived opt_union_order_or_limit
          {
            if ($1 && $2)
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
          }
        | select_derived_union
          UNION_SYM
          union_option
          {
            if (add_select_to_union_list(Lex, (bool)$3, FALSE))
              MYSQL_YYABORT;
          }
          query_specification
          {
            /*
              Remove from the name resolution context stack the context of the
              last select in the union.
             */
            Lex->pop_context();
          }
          opt_union_order_or_limit
          {
            if ($1 != NULL)
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
          }
        ;
query_expression_body:
          query_specification opt_union_order_or_limit
        | query_expression_body
          UNION_SYM union_option
          {
            if (add_select_to_union_list(Lex, (bool)$3, FALSE))
              MYSQL_YYABORT;
          }
          query_specification
          opt_union_order_or_limit
          {
            Lex->pop_context();
            $$= $1;
          }
        ;        
```
#20.select_derived_union
```cpp
/*
   This is a flattening of the rules <table factor> and <table primary>
   in the SQL:2003 standard, since we don't have <sample clause>

   I.e.
   <table factor> ::= <table primary> [ <sample clause> ]
*/
/* Warning - may return NULL in case of incomplete SELECT */
table_factor:
          /*
            Represents a flattening of the following rules from the SQL:2003
            standard. This sub-rule corresponds to the sub-rule
            <table primary> ::= ... | <derived table> [ AS ] <correlation name>

            The following rules have been flattened into query_expression_body
            (since we have no <with clause>).

            <derived table> ::= <table subquery>
            <table subquery> ::= <subquery>
            <subquery> ::= <left paren> <query expression> <right paren>
            <query expression> ::= [ <with clause> ] <query expression body>

            For the time being we use the non-standard rule
            select_derived_union which is a compromise between the standard
            and our parser. Possibly this rule could be replaced by our
            query_expression_body.
          */
        | '(' get_select_lex select_derived_union ')' opt_table_alias
          {
            /* Use $2 instead of Lex->current_select as derived table will
               alter value of Lex->current_select. */
            if (!($3 || $5) && $2->embedding &&
                !$2->embedding->nested_join->join_list.elements)
            {
              /* we have a derived table ($3 == NULL) but no alias,
                 Since we are nested in further parentheses so we
                 can pass NULL to the outer level parentheses
                 Permits parsing of "((((select ...))) as xyz)" */
              $$= 0;
            }
            else if (!$3)
            {
              /* Handle case of derived table, alias may be NULL if there
                 are no outer parentheses, add_table_to_list() will throw
                 error in this case */
              LEX *lex=Lex;
              SELECT_LEX *sel= lex->current_select;
              SELECT_LEX_UNIT *unit= sel->master_unit();
              lex->current_select= sel= unit->outer_select();
              Table_ident *ti= new Table_ident(unit);
              if (ti == NULL)
                MYSQL_YYABORT;
              if (!($$= sel->add_table_to_list(lex->thd,
                                               ti, $5, 0,
                                               TL_READ, MDL_SHARED_READ)))

                MYSQL_YYABORT;
              sel->add_joined_table($$);
              lex->pop_context();
              lex->nest_level--;
            }
            else if ($5 != NULL)
            {
              /*
                Tables with or without joins within parentheses cannot
                have aliases, and we ruled out derived tables above.
              */
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
            else
            {
              /* nested join: FROM (t1 JOIN t2 ...),
                 nest_level is the same as in the outer query */
              $$= $3;
            }
          }
        ;
```
#21. table_factor
```cpp
/* Equivalent to <table reference> in the SQL:2003 standard. */
/* Warning - may return NULL in case of incomplete SELECT */
table_ref:
          table_factor { $$=$1; }
        | join_table
          {
            LEX *lex= Lex;
            if (!($$= lex->current_select->nest_last_join(lex->thd)))
              MYSQL_YYABORT;
          }
        ;
        
/*
  Notice that JOIN is a left-associative operation, and it must be parsed
  as such, that is, the parser must process first the left join operand
  then the right one. Such order of processing ensures that the parser
  produces correct join trees which is essential for semantic analysis
  and subsequent optimization phases.
*/
join_table:
          /* INNER JOIN variants */
          /*
            Use %prec to evaluate production 'table_ref' before 'normal_join'
            so that [INNER | CROSS] JOIN is properly nested as other
            left-associative joins.
          */
          table_ref normal_join table_ref %prec TABLE_REF_PRIORITY
          { MYSQL_YYABORT_UNLESS($1 && ($$=$3)); }
        | table_ref STRAIGHT_JOIN table_factor
          { MYSQL_YYABORT_UNLESS($1 && ($$=$3)); $3->straight=1; }
        | table_ref normal_join table_ref
          ON
          {
            MYSQL_YYABORT_UNLESS($1 && $3);
            /* Change the current name resolution context to a local context. */
            if (push_new_name_resolution_context(YYTHD, $1, $3))
              MYSQL_YYABORT;
            Select->parsing_place= IN_ON;
          }
          expr
          {
            add_join_on($3,$6);
            Lex->pop_context();
            Select->parsing_place= NO_MATTER;
          }
        | table_ref STRAIGHT_JOIN table_factor
          ON
          {
            MYSQL_YYABORT_UNLESS($1 && $3);
            /* Change the current name resolution context to a local context. */
            if (push_new_name_resolution_context(YYTHD, $1, $3))
              MYSQL_YYABORT;
            Select->parsing_place= IN_ON;
          }
          expr
          {
            $3->straight=1;
            add_join_on($3,$6);
            Lex->pop_context();
            Select->parsing_place= NO_MATTER;
          }
        | table_ref normal_join table_ref
          USING
          {
            MYSQL_YYABORT_UNLESS($1 && $3);
          }
          '(' using_list ')'
          { add_join_natural($1,$3,$7,Select); $$=$3; }
        | table_ref NATURAL JOIN_SYM table_factor
          {
            MYSQL_YYABORT_UNLESS($1 && ($$=$4));
            add_join_natural($1,$4,NULL,Select);
          }

          /* LEFT JOIN variants */        
```
#22. table_ref
```cpp
/*
  The ODBC escape syntax for Outer Join is: '{' OJ join_table '}'
  The parser does not define OJ as a token, any ident is accepted
  instead in $2 (ident). Also, all productions from table_ref can
  be escaped, not only join_table. Both syntax extensions are safe
  and are ignored.
*/
esc_table_ref:
        table_ref { $$=$1; }
      | '{' ident table_ref '}' { $$=$3; }
      ;
/*
  Notice that JOIN is a left-associative operation, and it must be parsed
  as such, that is, the parser must process first the left join operand
  then the right one. Such order of processing ensures that the parser
  produces correct join trees which is essential for semantic analysis
  and subsequent optimization phases.
*/
join_table:
          /* INNER JOIN variants */
          /*
            Use %prec to evaluate production 'table_ref' before 'normal_join'
            so that [INNER | CROSS] JOIN is properly nested as other
            left-associative joins.
          */
          table_ref normal_join table_ref %prec TABLE_REF_PRIORITY
          { MYSQL_YYABORT_UNLESS($1 && ($$=$3)); }
        | table_ref STRAIGHT_JOIN table_factor
          { MYSQL_YYABORT_UNLESS($1 && ($$=$3)); $3->straight=1; }
        | table_ref normal_join table_ref
          ON
          {
            MYSQL_YYABORT_UNLESS($1 && $3);
            /* Change the current name resolution context to a local context. */
            if (push_new_name_resolution_context(YYTHD, $1, $3))
              MYSQL_YYABORT;
            Select->parsing_place= IN_ON;
          }
          expr
          {
            add_join_on($3,$6);
            Lex->pop_context();
            Select->parsing_place= NO_MATTER;
          }
        | table_ref STRAIGHT_JOIN table_factor
          ON      
```
#23.esc_table_ref
```cpp
/* Equivalent to <table reference list> in the SQL:2003 standard. */
/* Warning - may return NULL in case of incomplete SELECT */
derived_table_list:
          esc_table_ref { $$=$1; }
        | derived_table_list ',' esc_table_ref
          {
            MYSQL_YYABORT_UNLESS($1 && ($$=$3));
          }
        ;
```
#24. derived_table_list

```cpp
join_table_list:
          derived_table_list { MYSQL_YYABORT_UNLESS($$=$1); }
        ;
/* handle contents of parentheses in join expression */
select_derived:
          get_select_lex
          {
            LEX *lex= Lex;
            if ($1->init_nested_join(lex->thd))
              MYSQL_YYABORT;
          }
          derived_table_list
          {
            LEX *lex= Lex;
            /* for normal joins, $3 != NULL and end_nested_join() != NULL,
               for derived tables, both must equal NULL */

            if (!($$= $1->end_nested_join(lex->thd)) && $3)
              MYSQL_YYABORT;
            if (!$3 && $$)
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
          }
        ;        
```

#25.join_table_list
```cpp
select_from:
          FROM join_table_list where_clause group_clause having_clause
          opt_order_clause opt_limit_clause procedure_analyse_clause
          {
            Select->context.table_list=
              Select->context.first_name_resolution_table=
                Select->table_list.first;
          }

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

#26.select_derived
```cpp
/*
  This rule accepts just about anything. The reason is that we have
  empty-producing rules in the beginning of rules, in this case
  subselect_start. This forces bison to take a decision which rules to
  reduce by long before it has seen any tokens. This approach ties us
  to a very limited class of parseable languages, and unfortunately
  SQL is not one of them. The chosen 'solution' was this rule, which
  produces just about anything, even complete bogus statements, for
  instance ( table UNION SELECT 1 ).

  Fortunately, we know that the semantic value returned by
  select_derived is NULL if it contained a derived table, and a pointer to
  the base table's TABLE_LIST if it was a base table. So in the rule
  regarding union's, we throw a parse error manually and pretend it
  was bison that did it.

  Also worth noting is that this rule concerns query expressions in
  the from clause only. Top level select statements and other types of
  subqueries have their own union rules.
 */
select_derived_union:
          select_derived opt_union_order_or_limit
          {
            if ($1 && $2)
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
          }
```
#27.join_table
```cpp
/* Equivalent to <table reference> in the SQL:2003 standard. */
/* Warning - may return NULL in case of incomplete SELECT */
table_ref:
          table_factor { $$=$1; }
        | join_table
          {
            LEX *lex= Lex;
            if (!($$= lex->current_select->nest_last_join(lex->thd)))
              MYSQL_YYABORT;
          }
        ;
        
```
#28.query_expression_body
```cpp
/* Corresponds to <query expression> in the SQL:2003 standard. */
subselect:
          subselect_start query_expression_body subselect_end
          {
            $$= $2;
          }
        ;
```

#29.subselect
```cpp
bool_pri:
          bool_pri IS NULL_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_isnull($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri IS not NULL_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_isnotnull($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri EQUAL_SYM predicate %prec EQUAL_SYM
          {
            $$= new (YYTHD->mem_root) Item_func_equal($1,$3);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri comp_op predicate %prec EQ
          {
            $$= (*$2)(0)->create($1,$3);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri comp_op all_or_any '(' subselect ')' %prec EQ
          {
            $$= all_any_subquery_creator($1, $2, $3, $5);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | predicate
        ;

predicate:
          bit_expr IN_SYM '(' subselect ')'
          {
            $$= new (YYTHD->mem_root) Item_in_subselect($1, $4);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bit_expr not IN_SYM '(' subselect ')'
          {
            THD *thd= YYTHD;
            Item *item= new (thd->mem_root) Item_in_subselect($1, $5);
            if (item == NULL)
              MYSQL_YYABORT;
            $$= negate_expression(thd, item);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
simple_expr:
        | '(' subselect ')'
          {
            $$= new (YYTHD->mem_root) Item_singlerow_subselect($2);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }                  
```

#30.select_init2_derived
```cpp
query_specification:
          SELECT_SYM select_init2_derived
          {
            $$= Lex->current_select->master_unit()->first_select();
          }
        | '(' select_paren_derived ')'
          {
            $$= Lex->current_select->master_unit()->first_select();
          }
        ;


```

#31.select_derived2
```cpp
/*
   This is a flattening of the rules <table factor> and <table primary>
   in the SQL:2003 standard, since we don't have <sample clause>

   I.e.
   <table factor> ::= <table primary> [ <sample clause> ]
*/
/* Warning - may return NULL in case of incomplete SELECT */
table_factor:
          {
            SELECT_LEX *sel= Select;
            sel->table_join_options= 0;
          }
          table_ident opt_use_partition opt_table_alias opt_key_definition
          {
            if (!($$= Select->add_table_to_list(YYTHD, $2, $4,
                                                Select->get_table_join_options(),
                                                YYPS->m_lock_type,
                                                YYPS->m_mdl_type,
                                                Select->pop_index_hints(),
                                                $3)))
              MYSQL_YYABORT;
            Select->add_joined_table($$);
          }
        | select_derived_init get_select_lex select_derived2
```

#32.bool_pri
```cpp
/* all possible expressions */
expr:
        | bool_pri IS TRUE_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_istrue($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri IS not TRUE_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_isnottrue($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri IS FALSE_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_isfalse($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri IS not FALSE_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_isnotfalse($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri IS UNKNOWN_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_isnull($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri IS not UNKNOWN_SYM %prec IS
          {
            $$= new (YYTHD->mem_root) Item_func_isnotnull($1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bool_pri
        ;

        
```


#predicate
#simple_expr
