#1.trx_commit

```cpp

trx_commit(mtr)
  |- trx_write_serialisation_history(mtr)
    // 给事务分配trx→no
    |- trx_serialisation_number_get
    //Step 1. 设置事务对应的Undo Log Header中的TRX_UNDO_STATE为"提交"
    // InnoDB的Redo日志中没有Commit Record，通过TRX_UNDO_STATE来标识事务真正的提交
    |- trx_undo_set_state_at_finish(mtr)
    // Step 2. 将Undo Log Header加入到所在的Undo Segment->History List上，并适当增加TRX_RSEG_HISTORY_SIZE的值
    |- trx_undo_update_cleanup(mtr)
    // Step 3. 设置在系统表空间中的两个域（该事务提交后，Binlog写到的位置）：TRX_SYS_MYSQL_LOG_NAME/
    //         TRX_SYS_MYSQL_LOG_OFFSET
    |- trx_sys_update_mysql_binlog_offset(mtr)
    |- ...
```

#2.trx_commit_low

```cpp
trx_commit_low
--trx_write_commit_log
----log_ptr = mlog_write_initial_log_record_low(MLOG_TRX_COMMIT, 0, 0,log_ptr, mtr);
----mach_write_to_8(log_ptr, trx_id);
----mlog_close(mtr, log_ptr);
--mtr_t::commit
----mtr_t::Command::execute
------mtr_t::Command::prepare_write
------mtr_t::Command::finish_write
--------log_buffer_reserve
--------finish_write_header
--------for_each_block
----------mtr_parallel_write_log_t
------------log_buffer_write
------------log_buffer_write_completed
--------------Link_buf<unsigned long>::add_link
------------log_buffer_close
------mtr_t::Command::release_blocks
------mtr_t::Command::release_latches
------mtr_t::Command::release_resources
--trx_commit_in_memory
----trx_flush_log_if_needed
------trx_flush_log_if_needed_low
--------log_write_up_to
```