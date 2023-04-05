#1.Engine::GetTableIndex

```
Engine::GetTableIndex
--auto iter = m_table_keys.find(table_path);
--if (iter != m_table_keys.end()) {
    return iter->second;
  }
--return nullptr;
```