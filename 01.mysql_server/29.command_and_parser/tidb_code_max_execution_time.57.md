#max_execution_time

#1.is_timer_applicable_to_statement

```cpp
caller:
- set_statement_timer
- execute_sqlcom_select


is_timer_applicable_to_statement
--bool timer_value_is_set= (thd->lex->max_execution_time ||
                            thd->variables.max_execution_time);
  /**
    Following conditions are checked,
      - is SELECT statement.
      - timer support is implemented and it is initialized.
      - statement is not made by the slave threads.
      - timer is not set for statement
      - timer out value of is set
      - SELECT statement is not from any stored programs.
  */
--return (thd->lex->sql_command == SQLCOM_SELECT &&
          (have_statement_timeout == SHOW_OPTION_YES) &&
          !thd->slave_thread &&
          !thd->timer && timer_value_is_set &&
          !thd->sp_runtime_ctx);
```

#2. set_statement_timer

```cpp
set_statement_timer
--get_max_execution_time
--thd->timer= thd_timer_set(thd, thd->timer_cache, max_execution_time)
----thd_timer_create
----thd_timer->thread_id= thd->thread_id();
----my_timer_set
```