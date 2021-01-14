#1. dispatch_command

```cpp
caller
--do_command

/**
  Perform one connection-level (COM_XXXX) command.

  @param command         type of command to perform
  @param thd             connection handle
  @param packet          data for the command, packet is always null-terminated
  @param packet_length   length of packet + 1 (to show that data is
                         null-terminated) except for COM_SLEEP, where it
                         can be zero.

  @todo
    set thd->lex->sql_command to SQLCOM_END here.
  @todo
    The following has to be changed to an 8 byte integer

  @retval
    0   ok
  @retval
    1   request of thread shutdown, i. e. if command is
        COM_QUIT/COM_SHUTDOWN
*/
dispatch_command
--MYSQL_REFINE_STATEMENT/* Performance Schema Interface instrumentation, begin */
----inline_mysql_refine_statement
------refine_statement
--------refine_statement_v1
--switch (command) {
--case COM_QUERY:
----alloc_query
----MYSQL_SET_STATEMENT_TEXT
------inline_mysql_set_statement_text
--------set_statement_text
----------set_statement_text_v1
--mysql_parse
--thd->update_server_status();
--thd->protocol->end_statement()
----Protocol::send_eof
------net_send_eof
--------write_eof_packet
----------my_net_write
------------net_write_buff
--------------memcpy(net->write_pos, packet, len);
--------------
--mysql_audit_general
--MYSQL_END_STATEMENT(thd->m_statement_psi, thd->get_stmt_da());
--MYSQL_COMMAND_DONE(res);

```