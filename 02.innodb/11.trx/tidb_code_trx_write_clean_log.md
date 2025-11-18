#1.trx_write_clean_log

```cpp
caller:
--trx_rollback_or_clean_all_recovered

trx_write_clean_log
--mtr_start(&mtr);
--mlog_open(&mtr, MLOG_HEADER_LEN + 8, 0, 0);
--mlog_write_initial_log_record_low(MLOG_TRX_CLEAN, 0, 0,log_ptr, &mtr);
--mlog_close(&mtr, log_ptr);
--mtr.page_detach();
--mtr_commit(&mtr);
```