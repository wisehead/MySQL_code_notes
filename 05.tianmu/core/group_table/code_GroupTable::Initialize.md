#1.GroupTable::Initialize

```
GroupTable::Initialize
--declared_max_no_groups = max_no_groups;
--no_grouping_attr = int(grouping_desc.size());
--no_attr = no_grouping_attr + int(aggregated_desc.size());
--for (int i = 0; i < no_attr; i++) {
----if (i < no_grouping_attr) {
------desc = grouping_desc[i];
------vc[i] = desc.vc;
      // TODO: not always decodable? (hidden cols)
------encoder[i] = new ColumnBinEncoder(ColumnBinEncoder::ENCODER_DECODABLE);
------encoder[i]->PrepareEncoder(desc.vc);
--for (int i = 0; i < no_grouping_attr; i++) {
    encoder[i]->SetPrimaryOffset(grouping_buf_width);
    grouping_buf_width += encoder[i]->GetPrimarySize();
--for (int i = 0; i < no_grouping_attr; i++) {
    if (encoder[i]->GetSecondarySize() > 0) {
      encoder[i]->SetSecondaryOffset(grouping_and_UTF_width);
      grouping_and_UTF_width += encoder[i]->GetSecondarySize();
--// pre-allocation of group by memory
--max_size = std::max(max_no_groups * total_width * (1 + no_columns_with_distinct),
                              parallel_allowed ? max_no_groups * total_width * 4 : 0);
--max_total_size = mm::TraceableObject::MaxBufferSizeForAggr(int64_t(ceil(max_size * 1.3)));
--vm_tab.reset(ValueMatchingTable::CreateNew_ValueMatchingTable(primary_total_size, declared_max_no_groups,
                                                                max_group_code, total_width, grouping_and_UTF_width,
                                                                grouping_buf_width, p_power, false));
--input_buffer.resize(grouping_and_UTF_width);
--
```