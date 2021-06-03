#1. COM_QUERY Response

```cpp
dispatch_command
--mysql_parse
----mysql_execute_command
------execute_sqlcom_select
--------handle_query
----------JOIN::exec
------------Query_result_send::send_result_set_metadata//!!! send def 
------------do_select//do the real work.
--------------sub_select
----------------evaluate_join_record
------------------end_send
--------------------Query_result_send::send_data// !!!! send data
--THD::send_statement_status// !!! send ok or error. 
  switch (da->status())
  {
    case Diagnostics_area::DA_ERROR:
      /* The query failed, send error to log and abort bootstrap. */
      error= m_protocol->send_error(
              da->mysql_errno(), da->message_text(), da->returned_sqlstate());
          break;
    case Diagnostics_area::DA_EOF:
      error= m_protocol->send_eof(
              server_status, da->last_statement_cond_count());
          break;
    case Diagnostics_area::DA_OK:
      error= m_protocol->send_ok(
              server_status, da->last_statement_cond_count(),
              da->affected_rows(), da->last_insert_id(), da->message_text());
          break;
    case Diagnostics_area::DA_DISABLED:
      break;
    case Diagnostics_area::DA_EMPTY:
    default:
      DBUG_ASSERT(0);
          error= m_protocol->send_ok(server_status, 0, 0, 0, NULL);
          break;
  }
```