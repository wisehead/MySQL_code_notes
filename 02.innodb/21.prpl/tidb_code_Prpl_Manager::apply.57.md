#1.Prpl_Manager::apply

```cpp
Prpl_Manager::apply
--lsn_t log_group_end_lsn = log_group->m_end_lsn;
--lsn_t log_applied_lsn = rpl_sys->get_applied_lsn();
--for (ulint i = 0; i < m_n_workers; i++)
----m_workers[i]->notify();
--os_event_wait(m_done);
--apply_post_recs
----for (rpl_rec_t* rec = UT_LIST_GET_FIRST(log_group->m_post_recs);rec != NULL;rec = UT_LIST_GET_FIRST(log_group->m_post_recs))
------mtr_hdr = reinterpret_cast<mtr_log_header*>(rec->data);
------rpl_sys->apply_log_recs
------UT_LIST_REMOVE(log_group->m_post_recs, rec);
--log_group->m_mtrs.advance_tail(log_group_end_lsn);
--log_group->m_state = Log_Group::APPLY_FINISHED;
--rpl_sys->update_rpl_lag(log_group_end_lsn);
--rpl_sys->set_applied_lsn(log_group_end_lsn);
--buf_shm_set_applied_lsn(log_group_end_lsn);
--if (log_group->m_barrier == Log_Group::BARRIER_RTREE)
--log_group->empty_hash()
--advance_applying_id
--os_event_set(m_parse);
--rpl_sys->release_locks(m_thd, log_group_end_lsn);
--log_sys->sn  = log_translate_lsn_to_sn(log_group_end_lsn);
--log_sys->lsn = log_group_end_lsn;
--log_sys->write_lsn = log_group_end_lsn;
--log_sys->flushed_to_disk_lsn = log_group_end_lsn;
--log_sys->next_checkpoint_lsn = log_group_end_lsn;
--log_sys->last_checkpoint_lsn = log_group_end_lsn;
```