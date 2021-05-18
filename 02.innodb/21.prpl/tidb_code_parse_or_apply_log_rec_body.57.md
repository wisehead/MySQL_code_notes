#1.parse_or_apply_log_rec_body

```cpp
/** Try to parse a single log record body and also applies it if
specified.
@param[in]      thd             THD
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
@param[in]      can_use_dummy_index user thread apply redo log will not
use dummy index. dummy index is thread local and can be only used in
slave apply thread.
@return log record end, NULL if not a complete record */

parse_or_apply_log_rec_body
--case MLOG_META_CHANGE:
----if (ncdb_slave_mode())
------trx_slave_flush_ids
----ddl_opr_ctl->ncdb_parse_meta_change
```

#2.caller

```cpp
- TIDB_rpl_sys::apply_log_recs
```