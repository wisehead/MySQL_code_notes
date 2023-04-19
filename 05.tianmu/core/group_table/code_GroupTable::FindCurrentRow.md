#1.GroupTable::FindCurrentRow

```
GroupTable::FindCurrentRow
--existed = vm_tab->FindCurrentRow(input_buffer.data(), row, not_full);
--if (!existed && row != common::NULL_VALUE_64) {
----if (vm_tab->NoMoreSpace())
------not_full = false;
--if (no_grouping_attr > 0) {
----unsigned char *p = vm_tab->GetGroupingRow(row);
----for (int col = 0; col < no_grouping_attr; col++)
------encoder[col]->UpdateStatistics(p);  // encoders have their offsets inside
----unsigned char *p = vm_tab->GetAggregationRow(row);
----for (int col = no_grouping_attr; col < no_attr; col++)
------aggregator[col]->Reset(p + aggregated_col_offset[col]);  // prepare the row for contents

```