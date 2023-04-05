#1.TianmuTable::AsyncParseInsertRecords

```
TianmuTable::AsyncParseInsertRecords
--index_table = ha_tianmu_engine_->GetTableIndex(share->Path());
--DelayedInsertParser parser(m_attrs, insert_vec, share->PackSize(), index_table, m_tx);
--do
----to_prepare = share->PackSize() - (int)(m_attrs[0]->NumOfObj() % share->PackSize());
----no_of_rows_returned = parser.GetRows(to_prepare, vcs);
----real_loaded_rows = vcs[0].NumOfValues();
----no_dup_rows += (no_of_rows_returned - real_loaded_rows);
----if (real_loaded_rows > 0) {
------for (uint att = 0; att < m_attrs.size(); ++att) {
        res.insert(
            ha_tianmu_engine_->load_thread_pool.add_task(&TianmuAttr::LoadData, m_attrs[att].get(), &vcs[att], m_tx));
```