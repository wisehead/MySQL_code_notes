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
caller:
- execute_sqlcom_select


set_statement_timer
--get_max_execution_time
--thd->timer= thd_timer_set(thd, thd->timer_cache, max_execution_time)
----thd_timer_create
------thd_timer->timer.notify_function= timer_callback;
------my_timer_create(&thd_timer->timer)
----thd_timer->thread_id= thd->thread_id();
----my_timer_set
------timer_settime
```

#3.typedef struct st_thd_timer_info THD_timer_info

```cpp
struct st_thd_timer_info
{
  my_thread_id thread_id;
  my_timer_t timer;
  mysql_mutex_t mutex;
  bool destroy;
};
```

#4.typedef struct st_my_timer my_timer_t;

```cpp
typedef struct st_my_timer my_timer_t;

/* Non-copyable timer object. */
struct st_my_timer
{
  /* Timer ID used to identify the timer in timer requests. */
  os_timer_t id;

  /** Timer expiration notification function. */
  void (*notify_function)(my_timer_t *);
};
```

#5.timer_callback

```cpp
timer_callback
--timer_notify
```

#6.timer_notify

```cpp
  /*
    Statement might have finished while the timer notification
    was being delivered. If this is the case, the timer object
    was detached (orphaned) and has no associated session (thd).
  */
  if (thd)
  {
    /* process only if thread is not already undergoing any kill connection. */
    if (thd->killed != THD::KILL_CONNECTION)
    {
      thd->awake(THD::KILL_TIMEOUT);
    }
    mysql_mutex_unlock(&thd->LOCK_thd_data);
  }
```