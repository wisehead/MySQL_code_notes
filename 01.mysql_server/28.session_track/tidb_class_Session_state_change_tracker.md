#1.class Session_state_change_tracker

```cpp
/*
  Session_state_change_tracker
  ----------------------------
  This is a boolean tracker class that will monitor any change that contributes
  to a session state change.
  Attributes that contribute to session state change include:
     - Successful change to System variables
     - User defined variables assignments
     - temporary tables created, altered or deleted
     - prepared statements added or removed
     - change in current database
*/

class Session_state_change_tracker : public State_tracker
{
private:

  void reset();

public:
  Session_state_change_tracker();
  bool enable(THD *thd);
  bool check(THD *thd, set_var *var)
  { return false; }
  bool update(THD *thd);
  bool store(THD *thd, String &buf);
  void mark_as_changed(THD *thd, LEX_CSTRING *tracked_item_name);
  bool is_state_changed(THD*);
  void ensure_enabled(THD *thd)
  {}
};
```

#2.update_session_track_state_change

```cpp
update_session_track_state_change
--thd->session_tracker.get_tracker(SESSION_STATE_CHANGE_TRACKER)->update(thd)

(gdb) bt
#0  Session_state_change_tracker::enable (this=0x7f30c5e45740, thd=0x7f2e3edf9d40) at /home/chenhui/txsql-ncdb/sql/session_tracker.cc:1424
#1  0x0000000001547a90 in Session_state_change_tracker::update (this=0x7f30c5e45740, thd=0x7f2e3edf9d40) at /home/chenhui/txsql-ncdb/sql/session_tracker.cc:1438
#2  0x00000000016db5da in update_session_track_state_change (self=0x2fa72a0 <Sys_session_track_state_change>, thd=0x7f2e3edf9d40, type=OPT_SESSION) at /home/chenhui/txsql-ncdb/sql/sys_vars.cc:5856
#3  0x0000000001549bd0 in sys_var::update (this=0x2fa72a0 <Sys_session_track_state_change>, thd=0x7f2e3edf9d40, var=0x7f2e3f030ba8) at /home/chenhui/txsql-ncdb/sql/set_var.cc:198
#4  0x000000000154b19e in set_var::update (this=0x7f2e3f030ba8, thd=0x7f2e3edf9d40) at /home/chenhui/txsql-ncdb/sql/set_var.cc:805
#5  0x000000000154aae4 in sql_set_variables (thd=0x7f2e3edf9d40, var_list=0x7f2e3edfc680) at /home/chenhui/txsql-ncdb/sql/set_var.cc:665
#6  0x0000000001611a4b in mysql_execute_command (thd=0x7f2e3edf9d40, first_level=true) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:4392
#7  0x0000000001617653 in mysql_parse (thd=0x7f2e3edf9d40, parser_state=0x7f30bfcfcc30) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:6466
#8  0x000000000160ae21 in dispatch_command (thd=0x7f2e3edf9d40, com_data=0x7f30bfcfd450, command=COM_QUERY) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:1647
#9  0x000000000160964d in do_command (thd=0x7f2e3edf9d40) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:1074
#10 0x0000000001717fae in threadpool_process_request (thd=0x7f2e3edf9d40) at /home/chenhui/txsql-ncdb/sql/threadpool_common.cc:275
#11 0x000000000171b27d in handle_event (connection=0x7f30c5e48840) at /home/chenhui/txsql-ncdb/sql/threadpool_unix.cc:1605
#12 0x000000000171b4bf in worker_main (param=0x2fae200 <all_groups+2560>) at /home/chenhui/txsql-ncdb/sql/threadpool_unix.cc:1677
#13 0x00000000019fefab in pfs_spawn_thread (arg=0x7f30c2404320) at /home/chenhui/txsql-ncdb/storage/perfschema/pfs.cc:2188
#14 0x00007f30c790eea5 in start_thread () from /lib64/libpthread.so.0
#15 0x00007f30c65d296d in clone () from /lib64/libc.so.6
```