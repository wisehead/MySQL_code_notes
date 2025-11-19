#1.trx_undo_truncate_tablespace

```cpp
bool
trx_undo_truncate_tablespace(     //Truncate UNDO tablespace, reinitialize header and rseg.
    undo::Truncate*    undo_trunc)  //@param[in]undo_trunc，UNDO tablespace handler
{...
    /* Step-1: Truncate tablespace. */
    success = fil_truncate_tablespace(space_id, SRV_UNDO_TABLESPACE_SIZE_IN_PAGES);
...
    /* Step-2: Re-initialize tablespace header.
        Avoid REDO logging as we don't want to apply the action if server
        crashes. For fix-up we have UNDO-truncate-ddl-log. */
    mtr_t        mtr;
    mtr_start(&mtr);//开始Mini-Transaction
    mtr_set_log_mode(&mtr, MTR_LOG_NO_REDO);  //不记REDO日志
    fsp_header_init(space_id, SRV_UNDO_TABLESPACE_SIZE_IN_PAGES, &mtr);
    mtr_commit(&mtr);  //提交Mini-Transaction。这一段，是Mini-Transaction的一个典型用
                         法，进行资源管理（释放、清理）但不记录日志
    /* Step-3: Re-initialize rollback segment header that resides in truncated tablespaced. */
    mtr_start(&mtr);   //开始Mini-Transaction
    mtr_set_log_mode(&mtr, MTR_LOG_NO_REDO); //不记REDO日志
    mtr_x_lock(fil_space_get_latch(space_id, NULL), &mtr);
...
    mtr_commit(&mtr);  //提交Mini-Transaction。这一段，还是Mini-Transaction的一个
    典型用法，进行资源管理（释放、清理）但不记录日志
...
}

```