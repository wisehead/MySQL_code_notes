#1.recv_parse_or_apply_log_rec_body

```cpp
/** Try to parse a single log record body and also applies it if
specified.
@param[in]      type            redo log entry type
@param[in]      ptr             redo log record body
@param[in]      end_ptr         end of buffer
@param[in]      space_id        tablespace identifier
@param[in]      page_no         page number
@param[in]      apply           whether to apply the record
@param[in,out]  block           buffer block, or NULL if
a page log record should not be applied
or if it is a MLOG_FILE_ operation
@param[in,out]  mtr             mini-transaction, or NULL if
a page log record should not be applied
@return log record end, NULL if not a complete record */

mysql_declare_plugin
--innobase_init
----innobase_start_or_create_for_mysql
------recv_recovery_from_checkpoint_start
--------recv_group_scan_log_recs
----------recv_scan_log_recs
------------recv_parse_log_recs
--------------recv_parse_log_rec//single log record.
----------------recv_parse_or_apply_log_rec_body
------------------trx_apply_commit_log
```