#33.expr


```cpp
ev_schedule_time:
          EVERY_SYM expr interval
          {
            Lex->event_parse_data->item_expression= $2;
            Lex->event_parse_data->interval= $3;
          }
          ev_starts
          ev_ends
        | AT_SYM expr
          {
            Lex->event_parse_data->item_execute_at= $2;
          }
        ;
        
ev_starts:
          /* empty */
          {
            Item *item= new (YYTHD->mem_root) Item_func_now_local(0);
            if (item == NULL)
              MYSQL_YYABORT;
            Lex->event_parse_data->item_starts= item;
          }
        | STARTS_SYM expr
          {
            Lex->event_parse_data->item_starts= $2;
          }
        ;

ev_ends:
          /* empty */
        | ENDS_SYM expr
          {
            Lex->event_parse_data->item_ends= $2;
          }
        ;      

sp_cparams:
          sp_cparams ',' expr
          {
           Lex->value_list.push_back($3);
          }
        | expr
          {
            Lex->value_list.push_back($1);
          }
        ;
sp_opt_default:
        /* Empty */
          { $$ = NULL; }
        | DEFAULT
          { Lex->sphead->m_parser_data.push_expr_start_ptr(YY_TOKEN_END); }
          expr
          { $$ = $3; }
        ;
        
sp_proc_stmt_return:
          RETURN_SYM
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);

            sp->m_parser_data.push_expr_start_ptr(YY_TOKEN_END);
          }
          expr
sp_if:
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
            sp->m_parser_data.push_expr_start_ptr(YY_TOKEN_END);
          }
          expr

simple_case_stmt:
          CASE_SYM
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            case_stmt_action_case(thd);

            sp->reset_lex(thd); /* For CASE-expr $3 */
            sp->m_parser_data.push_expr_start_ptr(YY_TOKEN_END);
          }
          expr

simple_when_clause:
          WHEN_SYM
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
            sp->m_parser_data.push_expr_start_ptr(YY_TOKEN_END);
          }
          expr
searched_when_clause:
          WHEN_SYM
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
            sp->m_parser_data.push_expr_start_ptr(YY_TOKEN_END);
          }
          expr
sp_unlabeled_control:
          LOOP_SYM
          sp_proc_stmts1 END LOOP_SYM
          {
            THD *thd= YYTHD;
            LEX *lex= Lex;
            sp_head *sp= lex->sphead;
            sp_pcontext *pctx= lex->get_sp_current_parsing_ctx();

            sp_instr_jump *i=
                new (thd->mem_root)
                  sp_instr_jump(sp->instructions(), pctx,
                                pctx->last_label()->ip);

            if (!i || sp->add_instr(thd, i))
              MYSQL_YYABORT;
          }
        | WHILE_SYM
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            sp_head *sp= lex->sphead;

            sp->reset_lex(thd);
            sp->m_parser_data.push_expr_start_ptr(YY_TOKEN_END);
          }
          expr

check_constraint:
          CHECK_SYM '(' expr ')'
        ;

select_item:
          remember_name table_wild remember_end
          {
            THD *thd= YYTHD;

            if (add_item_to_list(thd, $2))
              MYSQL_YYABORT;
          }
        | remember_name expr remember_end select_alias

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
        | bit_expr IN_SYM '(' expr ')'

bit_expr:
        | bit_expr '+' INTERVAL_SYM expr interval %prec '+'
          {
            $$= new (YYTHD->mem_root) Item_date_add_interval($1,$4,$5,0);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | bit_expr '-' INTERVAL_SYM expr interval %prec '-'
          {
            $$= new (YYTHD->mem_root) Item_date_add_interval($1,$4,$5,1);
            if ($$ == NULL)
              MYSQL_YYABORT;
          } 
simple_expr:
        | '(' expr ')'
          { $$= $2; }
        | '(' expr ',' expr_list ')'
          {
            $4->push_front($2);
            $$= new (YYTHD->mem_root) Item_row(*$4);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }      
/*
  Function call syntax using official SQL 2003 keywords.
  Because the function name is an official token,
  a dedicated grammar rule is needed in the parser.
  There is no potential for conflicts
*/
function_call_keyword:
        | DATE_SYM '(' expr ')'
          {
            $$= new (YYTHD->mem_root) Item_date_typecast($3);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        | DAY_SYM '(' expr ')'
          {
            $$= new (YYTHD->mem_root) Item_func_dayofmonth($3);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }

/*
  Function calls using non reserved keywords, with special syntaxic forms.
  Dedicated grammar rules are needed because of the syntax,
  but also have the potential to cause incompatibilities with other
  parts of the language.
  MAINTAINER:
  The only reasons a function should be added here are:
  - for compatibility reasons with another SQL syntax (CURDATE),
  - for typing reasons (GET_FORMAT)
  Any other 'Syntaxic sugar' enhancements should be *STRONGLY*
  discouraged.
*/
function_call_nonkeyword:
          ADDDATE_SYM '(' expr ',' expr ')'
          {
            $$= new (YYTHD->mem_root) Item_date_add_interval($3, $5,
                                                             INTERVAL_DAY, 0);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }

/*
  Functions calls using a non reserved keyword, and using a regular syntax.
  Because the non reserved keyword is used in another part of the grammar,
  a dedicated rule is needed here.
*/
function_call_conflict:
          ASCII_SYM '(' expr ')'
          {
            $$= new (YYTHD->mem_root) Item_func_ascii($3);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
          
          
geometry_function:
          CONTAINS_SYM '(' expr ',' expr ')'
          {
            $$= GEOM_NEW(YYTHD,
                         Item_func_spatial_mbr_rel($3, $5,
                                               Item_func::SP_CONTAINS_FUNC));
          }

udf_expr:
          remember_name expr remember_end select_alias

sum_expr:
          AVG_SYM '(' in_sum_expr ')'
          {
            $$= new (YYTHD->mem_root) Item_sum_avg($3, FALSE);
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
variable_aux:
          ident_or_text SET_VAR expr
in_sum_expr:
          opt_all
          {
            LEX *lex= Lex;
            if (lex->current_select->inc_in_sum_expr())
            {
              my_parse_error(ER(ER_SYNTAX_ERROR));
              MYSQL_YYABORT;
            }
          }
          expr
          {
            Select->in_sum_expr--;
            $$= $3;
          }
        ;

expr_list:
          expr
          {
            $$= new (YYTHD->mem_root) List<Item>;
            if ($$ == NULL)
              MYSQL_YYABORT;
            $$->push_back($1);
          }
        | expr_list ',' expr
          {
            $1->push_back($3);
            $$= $1;
          }
        ;

opt_expr:
          /* empty */    { $$= NULL; }
        | expr           { $$= $1; }
        ;

opt_else:
          /* empty */  { $$= NULL; }
        | ELSE expr    { $$= $2; }
        ;

when_list:
          WHEN_SYM expr THEN_SYM expr
          {
            $$= new List<Item>;
            if ($$ == NULL)
              MYSQL_YYABORT;
            $$->push_back($2);
            $$->push_back($4);
          }
/*
  Notice that JOIN is a left-associative operation, and it must be parsed
  as such, that is, the parser must process first the left join operand
  then the right one. Such order of processing ensures that the parser
  produces correct join trees which is essential for semantic analysis
  and subsequent optimization phases.
*/
join_table:
          expr
          {
            add_join_on($3,$6);
            Lex->pop_context();
            Select->parsing_place= NO_MATTER;
          }

where_clause:
          /* empty */  { Select->where= 0; }
        | WHERE
          {
            Select->parsing_place= IN_WHERE;
          }
          expr
          {
            SELECT_LEX *select= Select;
            select->where= $3;
            select->parsing_place= NO_MATTER;
            if ($3)
              $3->top_level_item();
          }
        ;

having_clause:
          /* empty */
        | HAVING
          {
            Select->parsing_place= IN_HAVING;
          }
          expr
          {
            SELECT_LEX *sel= Select;
            sel->having= $3;
            sel->parsing_place= NO_MATTER;
            if ($3)
              $3->top_level_item();
          }
        ;
expr_or_default:
          expr { $$= $1;}
        | DEFAULT
          {
            $$= new (YYTHD->mem_root) Item_default_value(Lex->current_context());
            if ($$ == NULL)
              MYSQL_YYABORT;
          }
        ;
wild_and_where:
          /* empty */
        | LIKE TEXT_STRING_sys
          {
            Lex->wild= new (YYTHD->mem_root) String($2.str, $2.length,
                                                    system_charset_info);
            if (Lex->wild == NULL)
              MYSQL_YYABORT;
          }
        | WHERE expr
          {
            Select->where= $2;
            if ($2)
              $2->top_level_item();
          }
        ;
purge_option:
          TO_SYM TEXT_STRING_sys
          {
            Lex->to_log = $2.str;
          }
        | BEFORE_SYM expr
          {
            LEX *lex= Lex;
            lex->value_list.empty();
            lex->value_list.push_front($2);
            lex->sql_command= SQLCOM_PURGE_BEFORE;
          }
        ;

/* kill threads */

kill:
          KILL_SYM kill_option expr
          {
            LEX *lex=Lex;
            lex->value_list.empty();
            lex->value_list.push_front($3);
            lex->sql_command= SQLCOM_KILL;
          }
        ;
        
order_ident:
          expr { $$=$1; }
        ;
        
set_expr_or_default:
          expr { $$=$1; }

                                                                                                                                                                                                                                                                               
```
