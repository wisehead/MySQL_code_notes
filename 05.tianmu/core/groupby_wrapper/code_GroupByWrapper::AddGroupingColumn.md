#1.GroupByWrapper::AddGroupingColumn

```
GroupByWrapper::AddGroupingColumn
--virt_col[attr_no] = a.term.vc;
--is_lookup[attr_no] = false;
--dist_vals[attr_no] = common::NULL_VALUE_64;
--input_mode[attr_no] = GBInputMode::GBIMODE_NOT_SET;
--attr_mapping[orig_attr_no] = attr_no;
--gt.AddGroupingColumn(virt_col[attr_no]);
----GroupTable::AddGroupingColumn
--no_grouping_attr++;
--no_attr++;
```