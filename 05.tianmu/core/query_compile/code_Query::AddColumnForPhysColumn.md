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
--cq->AddColumn(at, tmp_table, CQTerm(vc.second), oper, group_by ? nullptr : item->item_name.ptr(), distinct);
--if (!group_by && item->item_name.ptr())
    field_alias2num[TabIDColAlias(tmp_table.n, alias ? alias : item->item_name.ptr())] = at.n;
```