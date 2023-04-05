#1.TianmuTable::AsyncParseInsertRecords

```
TianmuTable::AsyncParseInsertRecords
--index_table = ha_tianmu_engine_->GetTableIndex(share->Path());
--DelayedInsertParser parser(m_attrs, insert_vec, share->PackSize(), index_table, m_tx);
--to_prepare = share->PackSize() - (int)(m_attrs[0]->NumOfObj() % share->PackSize());
--no_of_rows_returned = parser.GetRows(to_prepare, vcs);
```