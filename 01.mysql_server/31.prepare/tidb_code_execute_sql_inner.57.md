#1.execute_sql_inner

```cpp
execute_sql_inner
--Parser_state parser_state;
--parser_state.init(thd, thd->query().str, thd->query().length)
--parser_state.m_lip.multi_statements= FALSE;
--lex_start(thd);
--parse_sql(thd, &parser_state, NULL)
--thd->lex->set_trg_event_type_for_tables()
--rewrite_query_if_needed(thd);
--log_execute_line(thd)
--mysql_execute_command
--lex_end(thd->lex);
--thd->get_stmt_da()->reset_diagnostics_area();

```

#2.caller

`read_client_proxy_reset_user`