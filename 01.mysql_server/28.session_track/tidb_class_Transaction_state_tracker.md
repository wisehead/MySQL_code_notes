#1.class Transaction_state_tracker

```cpp
class Transaction_state_tracker : public State_tracker
{
public:
  /** Constructor */
  Transaction_state_tracker();
  bool enable(THD *thd)
  { return update(thd); }
  bool check(THD *thd, set_var *var)
  { return false; }
  bool update(THD *thd);
  bool store(THD *thd, String &buf);
  void mark_as_changed(THD *thd, LEX_CSTRING *tracked_item_name);

  /** Change transaction characteristics */
  void set_read_flags(THD *thd, enum enum_tx_read_flags flags);
  void set_isol_level(THD *thd, enum enum_tx_isol_level level);

  /** Change transaction state */
  void clear_trx_state(THD *thd, uint clear);
  void add_trx_state(THD *thd, uint add);
  void add_trx_state_from_thd(THD *thd);
  void end_trx(THD *thd);

  /** Helper function: turn table info into table access flag */
  enum_tx_state calc_trx_state(THD *thd, thr_lock_type l, bool has_trx);

private:
  enum enum_tx_changed {
    TX_CHG_NONE     = 0,  ///< no changes from previous stmt
    TX_CHG_STATE    = 1,  ///< state has changed from previous stmt
    TX_CHG_CHISTICS = 2   ///< characteristics have changed from previous stmt
  };

  /** any trackable changes caused by this statement? */
  uint                     tx_changed;

  /** transaction state */
  uint                     tx_curr_state,  tx_reported_state;

  /** r/w or r/o set? session default? */
  enum enum_tx_read_flags  tx_read_flags;

  /**  isolation level */
  enum enum_tx_isol_level  tx_isol_level;

  void reset();

  inline void update_change_flags(THD *thd)
  {
    tx_changed &= ~TX_CHG_STATE;
    tx_changed |= (tx_curr_state != tx_reported_state) ? TX_CHG_STATE : 0;
    if (tx_changed != TX_CHG_NONE)
      mark_as_changed(thd, NULL);
  }
};
```

#2.end_trx

```cpp
caller:
- trans_commit
- trans_commit_implicit
- trans_rollback
- trans_rollback_implicit
- trans_xa_commit
- trans_xa_rollback



--trans_track_end_trx
----Transaction_state_tracker::end_trx
```

#3.Transaction_state_tracker::add_trx_state

```cpp
caller:
- track_table_access
- Transaction_state_tracker::add_trx_state_from_thd
- Locked_tables_list::init_locked_tables
- check_lock_and_start_stmt
- my_eof
- trans_begin



Transaction_state_tracker::add_trx_state
--update_change_flags
```

#4.enum enum\_tx\_state

```cpp
/**
  Transaction_state_tracker
  ----------------------
  This is a tracker class that enables & manages the tracking of
  current transaction info for a particular connection.
*/

/**
  Transaction state (no transaction, transaction active, work attached, etc.)
*/
enum enum_tx_state {
  TX_EMPTY        =   0,  ///< "none of the below"
  TX_EXPLICIT     =   1,  ///< an explicit transaction is active
  TX_IMPLICIT     =   2,  ///< an implicit transaction is active
  TX_READ_TRX     =   4,  ///<     transactional reads  were done
  TX_READ_UNSAFE  =   8,  ///< non-transaction   reads  were done
  TX_WRITE_TRX    =  16,  ///<     transactional writes were done
  TX_WRITE_UNSAFE =  32,  ///< non-transactional writes were done
  TX_STMT_UNSAFE  =  64,  ///< "unsafe" (non-deterministic like UUID()) stmts
  TX_RESULT_SET   = 128,  ///< result-set was sent
  TX_WITH_SNAPSHOT= 256,  ///< WITH CONSISTENT SNAPSHOT was used
  TX_LOCKED_TABLES= 512   ///< LOCK TABLES is active
};

```

#5.track_table_access

```cpp
caller:
handler_lock_table
--mysql_lock_tables


track_table_access
--tst = thd->session_tracker.get_tracker(TRANSACTION_INFO_TRACKER);
--while (count--)
----Transaction_state_tracker::calc_trx_state
----tst->add_trx_state(thd, s);
--//end while
```

#6.Transaction_state_tracker::add_trx_state_from_thd

```cpp
caller:
- sp_head::execute_procedure
- sp_lex_instr::reset_lex_and_exec_core
- continue_execute_cmd_unfinished_task
- mysql_execute_command


Transaction_state_tracker::add_trx_state_from_thd
--if (thd->lex->is_stmt_unsafe())
----get_stmt_unsafe_flags
------binlog_stmt_flags & BINLOG_STMT_UNSAFE_ALL_FLAGS
----add_trx_state(thd, TX_STMT_UNSAFE);
```

#7.continue_execute_cmd_unfinished_task

```cpp
/**
  We should continue unfinished task like sync commit.
  in sync commit, after innodb commit, the common return stack is like:

    mysql_execute_command
      ->mysql_parse
        ->dispatch_command
          ->do_command
            ->threadpool_process_request
              ->handle_event

  in async commit, we continue relevant task in continue_XXX_unfinished_task
  for ordinary commit, the async commit stack is:

    continue_execute_cmd_unfinished_task
      ->continue_parse_unfinished_task
        ->continue_dispatch_cmd_unfinished_task
          ->continue_threadpool_unfinished_task

  for prepared statement commit(SQLCOM_EXECUTE or COM_STMT_EXECUTE), the sync commit stack is like:

    mysql_execute_command
      ->Prepared_statement::execute
        ->Prepared_statement::execute_loop
          // for SQLCOM_EXECUTE          // for COM_STMT_EXECUTE
          ->mysql_sql_stmt_execute       ->mysqld_stmt_execute
            ->mysql_execute_command        ->dispatch_command
              ->mysql_parse                  ->do_command
                ->dispatch_command             ->threadpool_process_request
                  ->do_command                   ->handle_event
                    ->threadpool_process_request
                      ->handle_event

   the async commit stack is:

    continue_execute_cmd_unfinished_task
      ->continue_unfinished_pst_cmd
        ->continue_parse_unfinished_task  // SQLCOM_EXECUTE
          ->continue_dispatch_cmd_unfinished_task
            ->continue_threadpool_unfinished_task
 */
 
worker_main 
--handle_event
----continue_unfinished_task
------continue_execute_cmd_unfinished_task
```

#8.check_lock_and_start_stmt

```cpp
caller:
- open_ltable
- lock_tables


check_lock_and_start_stmt
--ha_innobase::start_stmt
```

#9.Transaction_state_tracker::clear_trx_state

```cpp
caller:
- unlock_locked_tables



Transaction_state_tracker::clear_trx_state
--tx_curr_state &= ~clear;
--update_change_flags(thd);
```

#10.THD::send_statement_status

```cpp
net_send_ok
--protocol->has_client_capability(CLIENT_SESSION_TRACK)
--Session_tracker::enabled_any
--Session_tracker::changed_any
```



















