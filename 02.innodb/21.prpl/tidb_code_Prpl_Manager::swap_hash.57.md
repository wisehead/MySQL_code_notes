#1.Prpl_Manager::swap_hash

```cpp
Prpl_Manager::swap_hash
--if (type == Log_Group::TYPE_PARSE)
----os_event_wait_for(m_parse, 0, 1000, stop_condition)
----log_group = m_log_groups[m_parsing_id.load() % m_n_log_group];
----log_group->m_id = m_parsing_id.load();
----m_parsing_group = log_group;
--else
----os_event_wait_for(m_apply, 0, 1000, stop_condition);
----log_group = m_log_groups[m_applying_id.load() % m_n_log_group];
----log_group->m_id = m_applying_id.load();
----m_applying_group = log_group;
```