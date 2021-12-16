#1.Prpl_Manager::prepare

```cpp
Prpl_Manager::prepare
--for (const auto &space : *(m_applying_group->m_spaces))
----space_id = space.first;
----for (auto pages : space.second.m_pages)
------slot = pages.second;
------m_workers[(counter++ % m_n_workers)]->add_redo(slot)
--------UT_LIST_ADD_LAST(m_slots, slot);
--rpl_sys->set_read_lsn(m_applying_group->m_end_lsn);
---- m_read_lsn = lsn;
```

#2.caller:Prpl_Manager::run()