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
--mysql_audit_general
--MYSQL_END_STATEMENT(thd->m_statement_psi, thd->get_stmt_da());
--MYSQL_COMMAND_DONE(res);
```

#2.do_command
```cpp
caller:
--do_handle_one_connection

/**
  Read one command from connection and execute it (query or simple command).
  This function is called in loop from thread function.

  For profiling to work, it must never be called recursively.

  @retval
    0  success
  @retval
    1  request of thread shutdown (see dispatch_command() description)
*/
do_command
--my_net_read
--command= (enum enum_server_command) (uchar) packet[0];
--dispatch_command
```

#3.handle_one_connection

```cpp
caller:
--pfs_spawn_thread

/*
  Thread handler for a connection

  SYNOPSIS
    handle_one_connection()
    arg   Connection object (THD)

  IMPLEMENTATION
    This function (normally) does the following:
    - Initialize thread
    - Initialize THD to be used with this thread
    - Authenticate user
    - Execute all queries sent on the connection
    - Take connection down
    - End thread  / Handle next connection using thread from thread cache
*/

handle_one_connection
--mysql_thread_set_psi_id
----get_thread
----set_thread_id
--do_handle_one_connection
----thd_prepare_connection
----while (thd_is_connection_alive(thd))
----do_command//in while
--end_connection(thd)
--close_connection(thd);
```