#1.InsertIndex

```
InsertIndex
--size_t row_idx = vcs[0].NumOfValues() - 1;
    std::vector<uint> cols = index_table->KeyCols();
    std::vector<std::string> fields;
--for (auto &col : cols) {
      fields.emplace_back(vcs[col].GetDataBytesPointer(row_idx), vcs[col].Size(row_idx));
--
```