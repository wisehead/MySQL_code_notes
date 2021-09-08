#1.killall_non_tencent_threads

```cpp
tidb_code_killall_non_tencent_threads
--Kill_non_tencent_conn kill_non_tencent_conn(thd);
--thd_manager->do_for_all_thd(&kill_non_tencent_conn);
```


#2.caller

-- cdb_working_mode_monitor_thread
-- update_cdb_working_mode


#3. cdb_working_mode_monitor_thread

```cpp
cdb_working_mode_monitor_thread
--my_thread_init
--while (!connection_events_loop_aborted())
----clock_gettime(CLOCK_MONOTONIC, &tpstart);
----if (tpstart.tv_sec > cdb_workmode_life_interval)//超时
------set_mysqld_cdb_working_mode(CDB_WORKMODE_OFFLINE);
--------cdb_working_mode.store(value);
------if (mysqld_cdb_working_mode_enabled())
--------killall_non_tencent_threads(NULL);
```