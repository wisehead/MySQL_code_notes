#1.NCDB_DDL_Opr_Ctl::ncdb_log_meta_change

```cpp
NCDB_DDL_Opr_Ctl::ncdb_log_meta_change
--mtr_start(&mtr);
--mlog_open
--mlog_write_initial_log_record_low
----if (mtr->write_header())
------log_ptr += MTR_LOG_HEADER_SIZE;
------if (NCDB_LOG_NOT_OP(type))
------else
----mach_write_to_1(log_ptr, type);//MLOG_META_CHANGE
----log_ptr++;
----mtr_t::added_rec
------++m_impl.m_n_log_recs;
--mach_write_to_1(ptr, type);//META_CHANGE_START
--ptr += 1;
--len += 1;
--mach_write_to_1(ptr, mdl_type);//MDL_key::TABLE
--ptr += 1;
--len += 1;
--mach_write_to_4(ptr, strlen(db));//db length
--ptr += 4;
--len += 4;
--mach_write_to_4(ptr, strlen(object_name));/* Store the object_name length */
--ptr += 4;
--len += 4;
--mlog_close(&mtr, ptr);
--mlog_catenate_string(&mtr, (byte *)db, strlen(db));/* Store the db */
--len += strlen(db);
--mlog_catenate_string(&mtr, (byte *)object_name, strlen(object_name));/* Store the object_name*/
--len += strlen(object_name);
--mtr.page_detach();//干吗的？？？？
--ncdb_master_info->lock_ddl();
--mtr_commit(&mtr);
--if (type == META_CHANGE_START)
----ncdb_master_info->ncdb_add_ddl_opr(mdl_type, db, object_name, mtr.commit_lsn());
--ncdb_master_info->unlock_ddl();
--log_write_up_to(mtr.commit_lsn(), true);
```