#1.Query::AddColumnForPhysColumn

```
Query::AddColumnForPhysColumn
--FieldUnmysterify
--if (base_table.IsNullID()) {
----vc = VirtualColumnAlreadyExists(tmp_table, tab, col);
----if (vc.first == common::NULL_VALUE_32) {
------vc.first = tmp_table.n;
      cq->CreateVirtualColumn(vc.second, tmp_table, tab, col);
      phys2virt.insert(std::make_pair(std::make_pair(tab.n, col.n), vc));
----
```