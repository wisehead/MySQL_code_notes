#1.Engine::GetTableIterator

```
Engine::GetTableIterator
--table = GetTx(thd)->GetTableByPath(table_path);
--iter_begin = table->Begin(attrs);
----TianmuTable::Iterator::CreateBegin
------ret.Initialize(attrs);
------ret.it.Rewind();
------if (ret.it.IsValid())
--------ret.position = *(ret.it);
------ret.conn = current_txn_;
--iter_end = table->End();
```